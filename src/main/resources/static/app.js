/* DB Web UI - Vanilla JS
   - Tabs por tabla
   - Listado (SELECT * LIMIT 100)
   - Alta (INSERT) y edición (UPDATE) con modal
   - Consola: SOLO SELECT
*/

const state = {
  tables: [],
  currentKey: null,
  currentMeta: null,
  currentRows: [],
  mode: null, // 'insert' | 'edit'
  editRow: null,
};

const $ = (id) => document.getElementById(id);

const el = {
  status: $('status'),
  tabList: $('tabList'),
  viewTitle: $('viewTitle'),
  viewHint: $('viewHint'),
  emptyState: $('emptyState'),
  tableWrap: $('tableWrap'),
  metaPill: $('metaPill'),
  dataTable: $('dataTable'),
  reloadRowsBtn: $('reloadRowsBtn'),
  newRowBtn: $('newRowBtn'),
  queryWrap: $('queryWrap'),
  queryInput: $('queryInput'),
  queryTable: $('queryTable'),
  runQueryBtn: $('runQueryBtn'),
  refreshBtn: $('refreshBtn'),
  modal: $('modal'),
  modalBackdrop: $('modalBackdrop'),
  modalClose: $('modalClose'),
  modalCancel: $('modalCancel'),
  modalSave: $('modalSave'),
  modalTitle: $('modalTitle'),
  modalSubtitle: $('modalSubtitle'),
  modalForm: $('modalForm'),
};

function setStatus(msg, tone = 'muted') {
  el.status.textContent = msg;
  el.status.style.color = tone === 'ok' ? 'var(--accent2)' : tone === 'err' ? 'var(--danger)' : 'var(--muted)';
}

async function api(path, opts = {}) {
  const res = await fetch(path, {
    headers: { 'Content-Type': 'application/json' },
    ...opts,
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(data?.error || `HTTP ${res.status}`);
  }
  return data;
}

function clearActiveTabs() {
  [...el.tabList.querySelectorAll('.tab')].forEach((t) => t.classList.remove('active'));
}

function makeTab(name, key, chipText) {
  const btn = document.createElement('button');
  btn.className = 'tab';
  btn.type = 'button';
  btn.dataset.key = key;

  const left = document.createElement('div');
  left.className = 'tabName';
  left.textContent = name;

  const chip = document.createElement('div');
  chip.className = 'tabChip';
  chip.textContent = chipText || 'tabla';

  btn.appendChild(left);
  btn.appendChild(chip);

  btn.addEventListener('click', () => activate(key));
  return btn;
}

function showView(which) {
  // which: 'empty' | 'table' | 'query'
  el.emptyState.classList.toggle('hidden', which !== 'empty');
  el.tableWrap.classList.toggle('hidden', which !== 'table');
  el.queryWrap.classList.toggle('hidden', which !== 'query');
}

async function loadTabs() {
  setStatus('Leyendo tablas...');
  const tables = await api('/api/tables');
  state.tables = tables;

  el.tabList.innerHTML = '';

  // tabs for tables
  for (const t of tables) {
    el.tabList.appendChild(makeTab(t, t, 'tabla'));
  }

  // extra tab for queries
  el.tabList.appendChild(makeTab('Consultas', '__query__', 'SELECT'));

  // Helpful default query
  if (tables.length > 0) {
    el.queryInput.value = `Aquí pon tu consulta amore`;
  }

  setStatus(`Listo. Tablas detectadas: ${tables.length}.`, 'ok');

  // Auto-open first table if exists
  if (tables.length > 0) {
    activate(tables[0]);
  } else {
    el.viewTitle.textContent = 'No hay tablas en la BD';
    el.viewHint.textContent = 'Crea al menos una tabla para que aparezca aquí.';
    showView('empty');
  }
}

async function activate(key) {
  state.currentKey = key;
  state.currentMeta = null;
  state.currentRows = [];

  clearActiveTabs();
  const tab = el.tabList.querySelector(`.tab[data-key="${CSS.escape(key)}"]`);
  if (tab) tab.classList.add('active');

  if (key === '__query__') {
    el.viewTitle.textContent = 'Consultas en SQL';
    el.viewHint.textContent = 'Solamente para consultas SELECT.';

    el.newRowBtn.disabled = true;
    el.reloadRowsBtn.disabled = true;

    showView('query');
    return;
  }

  // table view
  el.viewTitle.textContent = `Tabla: ${key}`;
  el.viewHint.textContent = 'Cargando metadata y filas...';
  showView('table');

  el.newRowBtn.disabled = false;
  el.reloadRowsBtn.disabled = false;

  await loadTable(key);
}

async function loadTable(tableName) {
  try {
    setStatus(`Cargando ${tableName}...`);
    const [meta, rowsResp] = await Promise.all([
      api(`/api/table/${encodeURIComponent(tableName)}/meta`),
      api(`/api/table/${encodeURIComponent(tableName)}/rows?limit=100&offset=0`),
    ]);

    state.currentMeta = meta;
    state.currentRows = rowsResp.rows || [];

    const pk = (meta.primaryKeyColumns || []).join(', ');
    el.metaPill.textContent = pk ? `PK: ${pk}` : 'Sin PK';

    renderTable(el.dataTable, meta, state.currentRows, true);

    el.viewHint.textContent = `Tiene ${state.currentRows.length} filas.`;
    setStatus(`Tabla cargada :p`, 'ok');
  } catch (e) {
    setStatus(e.message, 'err');
    el.viewHint.textContent = 'Error al cargar tabla ;(.';
    el.dataTable.innerHTML = '';
  }
}

function renderTable(tableEl, meta, rows, withActions) {
  tableEl.innerHTML = '';

  const cols = (meta?.columns || []).map((c) => c.name);
  const pkCols = meta?.primaryKeyColumns || [];

  const thead = document.createElement('thead');
  const hr = document.createElement('tr');
  for (const c of cols) {
    const th = document.createElement('th');
    th.textContent = c;
    hr.appendChild(th);
  }
  if (withActions) {
    const th = document.createElement('th');
    th.textContent = 'Acciones';
    hr.appendChild(th);
  }
  thead.appendChild(hr);
  tableEl.appendChild(thead);

  const tbody = document.createElement('tbody');
  for (const row of rows) {
    const tr = document.createElement('tr');
    for (const c of cols) {
      const td = document.createElement('td');
      const v = row?.[c];
      td.textContent = v === null || v === undefined ? 'NULL' : String(v);
      if (v === null || v === undefined) td.style.color = 'var(--muted)';
      tr.appendChild(td);
    }

    if (withActions) {
      const td = document.createElement('td');
      const wrap = document.createElement('div');
      wrap.className = 'rowActions';

      const editBtn = document.createElement('button');
      editBtn.className = 'linkBtn';
      editBtn.type = 'button';
      editBtn.textContent = 'Editar';

      // UI supports editing only if there is a SINGLE primary key
      editBtn.addEventListener('click', () => {
        if (!pkCols || pkCols.length !== 1) {
          setStatus('Para editar, la tabla necesita PK de 1 sola columna (PRIMARY KEY).', 'err');
          return;
        }
        openModal('edit', meta, row);
      });

      wrap.appendChild(editBtn);
      td.appendChild(wrap);
      tr.appendChild(td);
    }

    tbody.appendChild(tr);
  }
  tableEl.appendChild(tbody);
}

function openModal(mode, meta, row) {
  state.mode = mode;
  state.editRow = row || null;

  const cols = meta.columns || [];
  const pkCols = meta.primaryKeyColumns || [];

  el.modalTitle.textContent = mode === 'insert' ? 'Nuevo registro' : 'Editar registro';
  el.modalSubtitle.textContent = mode === 'insert'
    ? `Tabla: ${meta.table}`
    : `Tabla: ${meta.table} | PK: ${pkCols.join(', ')}`;

  el.modalForm.innerHTML = '';

  for (const c of cols) {
    const field = document.createElement('div');
    field.className = 'field';

    const label = document.createElement('div');
    label.className = 'label';
    label.textContent = `${c.name} (${c.dataType})`;

    const input = document.createElement('input');
    input.className = 'input';
    input.name = c.name;
    input.placeholder = c.nullable ? 'NULL' : 'requerido';

    // Prefill for edit
    if (mode === 'edit') {
      const v = row?.[c.name];
      input.value = v === null || v === undefined ? '' : String(v);
    }

    // Disable PK fields on edit
    if (mode === 'edit' && pkCols.includes(c.name)) {
      input.disabled = true;
    }

    // For insert, if autoIncrement, allow blank but show hint
    if (mode === 'insert' && c.autoIncrement) {
      input.placeholder = 'AUTO (deja vacío)';
    }

    field.appendChild(label);
    field.appendChild(input);
    el.modalForm.appendChild(field);
  }

  el.modal.classList.remove('hidden');
  el.modal.setAttribute('aria-hidden', 'false');
}

function closeModal() {
  el.modal.classList.add('hidden');
  el.modal.setAttribute('aria-hidden', 'true');
  state.mode = null;
  state.editRow = null;
}

function readFormValues() {
  const values = {};
  const inputs = [...el.modalForm.querySelectorAll('input')];
  for (const input of inputs) {
    const raw = input.value;
    // Interpret empty as null (so auto_increment can be omitted)
    values[input.name] = raw === '' ? null : raw;
  }
  return values;
}

async function saveModal() {
  const key = state.currentKey;
  const meta = state.currentMeta;
  if (!meta || !key || key === '__query__') return;

  const values = readFormValues();

  try {
    if (state.mode === 'insert') {
      await api(`/api/table/${encodeURIComponent(key)}/insert`, {
        method: 'POST',
        body: JSON.stringify(values),
      });
      setStatus('Insert OK. Recargando...', 'ok');
      closeModal();
      await loadTable(key);
      return;
    }

    if (state.mode === 'edit') {
      const pkCols = meta.primaryKeyColumns || [];
      if (pkCols.length !== 1) {
        throw new Error('Editar requiere PK de 1 columna (PRIMARY KEY).');
      }
      const pkColumn = pkCols[0];
      const pkValue = state.editRow?.[pkColumn];

      await api(`/api/table/${encodeURIComponent(key)}/update`, {
        method: 'POST',
        body: JSON.stringify({ pkColumn, pkValue, values }),
      });
      setStatus('Update OK. Recargando...', 'ok');
      closeModal();
      await loadTable(key);
      return;
    }
  } catch (e) {
    setStatus(e.message, 'err');
  }
}

async function runQuery() {
  try {
    const sql = el.queryInput.value;
    setStatus('Ejecutando SELECT...', 'muted');
    const resp = await api('/api/query', {
      method: 'POST',
      body: JSON.stringify({ sql }),
    });

    // Render as a table using a fake meta from keys
    const rows = resp.rows || [];
    const keys = rows.length > 0 ? Object.keys(rows[0]) : [];
    const meta = { columns: keys.map((k) => ({ name: k, dataType: 'any', nullable: true, primaryKey: false, autoIncrement: false })) };

    renderTable(el.queryTable, meta, rows, false);
    setStatus(resp.note || `Listo. Filas: ${rows.length}`, 'ok');
  } catch (e) {
    setStatus(e.message, 'err');
    el.queryTable.innerHTML = '';
  }
}

// Wire up buttons
el.refreshBtn.addEventListener('click', () => loadTabs());
el.reloadRowsBtn.addEventListener('click', async () => {
  if (state.currentKey && state.currentKey !== '__query__') {
    await loadTable(state.currentKey);
  }
});
el.newRowBtn.addEventListener('click', () => {
  if (!state.currentMeta) return;
  openModal('insert', state.currentMeta, null);
});

el.modalBackdrop.addEventListener('click', closeModal);
el.modalClose.addEventListener('click', closeModal);
el.modalCancel.addEventListener('click', closeModal);
el.modalSave.addEventListener('click', saveModal);

el.runQueryBtn.addEventListener('click', runQuery);

// Init
loadTabs().catch((e) => setStatus(e.message, 'err'));
