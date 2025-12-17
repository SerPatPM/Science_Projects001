-- Primero vamos a crear la base de datos science_projects
CREATE DATABASE IF NOT EXISTS science_projects
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_spanish_ci;

USE science_projects;

-- Nos aseguramos que las tablas sean eliminadas si ya existen

DROP TABLE IF EXISTS requisito;
DROP TABLE IF EXISTS actividad;
DROP TABLE IF EXISTS proyecto_participante;
DROP TABLE IF EXISTS participante;
DROP TABLE IF EXISTS area_cientifica;
DROP TABLE IF EXISTS proyecto;
DROP TABLE IF EXISTS tipo_participante;
DROP TABLE IF EXISTS pais;

-- Creamos las tablas necesarias para la base de datos

-- PAIS
CREATE TABLE pais (
    id_pais    INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    codigo_iso CHAR(2)
) ENGINE=InnoDB;

-- TIPO_PARTICIPANTE
CREATE TABLE tipo_participante (
    id_tipo_participante INT AUTO_INCREMENT PRIMARY KEY,
    nombre               VARCHAR(50) NOT NULL,
    descripcion          VARCHAR(255)
) ENGINE=InnoDB;

-- area cientifica
CREATE TABLE area_cientifica (
    id_area INT AUTO_INCREMENT PRIMARY KEY,
    nombre  VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- PROYECTO
CREATE TABLE proyecto (
    id_proyecto      INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(200) NOT NULL,
    resumen          TEXT,
    objetivo         TEXT,
    nivel_educativo  VARCHAR(100),
    sitio_web        VARCHAR(255),
    fecha_inicio     DATE,
    fecha_fin        DATE,
    id_area          INT,
    CONSTRAINT fk_proyecto_area
        FOREIGN KEY (id_area)
        REFERENCES area_cientifica (id_area)
) ENGINE=InnoDB;

-- PARTICIPANTE
CREATE TABLE participante (
    id_participante       INT AUTO_INCREMENT PRIMARY KEY,
    nombre                VARCHAR(150) NOT NULL,
    institucion           VARCHAR(200),
    email                 VARCHAR(150),
    id_pais               INT,
    id_tipo_participante  INT,
    CONSTRAINT fk_participante_pais
        FOREIGN KEY (id_pais)
        REFERENCES pais (id_pais),
    CONSTRAINT fk_participante_tipo
        FOREIGN KEY (id_tipo_participante)
        REFERENCES tipo_participante (id_tipo_participante)
) ENGINE=InnoDB;

-- PROYECTO_PARTICIPANTE
CREATE TABLE proyecto_participante (
    id_proyecto     INT,
    id_participante INT,
    rol             VARCHAR(100),
    PRIMARY KEY (id_proyecto, id_participante),
    CONSTRAINT fk_pp_proyecto
        FOREIGN KEY (id_proyecto)
        REFERENCES proyecto (id_proyecto),
    CONSTRAINT fk_pp_participante
        FOREIGN KEY (id_participante)
        REFERENCES participante (id_participante)
) ENGINE=InnoDB;

-- ACTIVIDAD
CREATE TABLE actividad (
    id_actividad      INT AUTO_INCREMENT PRIMARY KEY,
    id_proyecto       INT NOT NULL,
    titulo            VARCHAR(150) NOT NULL,
    descripcion       TEXT,
    tipo_actividad    VARCHAR(100),
    duracion_estimada VARCHAR(50),
    CONSTRAINT fk_actividad_proyecto
        FOREIGN KEY (id_proyecto)
        REFERENCES proyecto (id_proyecto)
) ENGINE=InnoDB;

-- REQUISITO
CREATE TABLE requisito (
    id_requisito  INT AUTO_INCREMENT PRIMARY KEY,
    id_proyecto   INT NOT NULL,
    descripcion   TEXT NOT NULL,
    obligatorio   BOOLEAN DEFAULT 1,
    CONSTRAINT fk_requisito_proyecto
        FOREIGN KEY (id_proyecto)
        REFERENCES proyecto (id_proyecto)
) ENGINE=InnoDB;

INSERT INTO pais (nombre, codigo_iso) VALUES
('Estados Unidos','US'),('España','ES'),('México','MX'),('Colombia','CO'),('Argentina','AR'),
('Reino Unido','GB'),('India','IN'),('Brasil','BR'),('Canadá','CA'),('Australia','AU');

INSERT INTO tipo_participante (nombre, descripcion) VALUES
('Estudiante','Alumno participante'),('Profesor','Docente guía'),('Investigador','Experto'),('Padre/Madre','Apoyo familiar'),('Colaborador externo','Voluntario');

INSERT INTO area_cientifica (nombre) VALUES
('Biología'),('Física'),('Química'),('Ciencias Tierra'),('Biología Marina'),
('Astronomía'),('Ingeniería'),('Geología'),('Ecología'),('Química Ambiental'),
('Ambiental'),('Entomología');

INSERT INTO proyecto (nombre,resumen,objetivo,id_area,nivel_educativo,sitio_web,fecha_inicio,fecha_fin) VALUES
('Descubriendo Ecosistemas','Exploración de hábitats locales','Comprender interdependencia',1,'Primaria','http://studentsdiscover.org/eco','2024-09-01','2024-12-15'),
('Máquinas Simples en Acción','Construcción de palancas y poleas','Aplicar física mecánica',2,'Primaria','http://studentsdiscover.org/maq','2024-09-10','2024-12-20'),
('Vida Marina Oculta','Acuarios caseros con organismos','Adaptaciones marinas',5,'Secundaria','http://studentsdiscover.org/mar','2024-10-01','2025-02-28'),
('Experimentos Químicos Seguros','Reacciones con materiales hogar','Cambios químicos',3,'Primaria','http://studentsdiscover.org/qui','2024-09-15','2024-12-10'),
('El Ciclo del Agua','Simulación ciclo hidrológico','Evaporación y precipitación',4,'Primaria','http://studentsdiscover.org/agua','2024-10-05','2025-01-15'),
('Fotosíntesis en Acción','Experimentos luz y plantas','Producción alimento vegetal',1,'Secundaria','http://studentsdiscover.org/foto','2024-09-20','2024-12-20'),
('Circuitos Eléctricos','Serie y paralelo con bombillas','Flujo electricidad',2,'Secundaria','http://studentsdiscover.org/cir','2024-10-01','2025-01-30'),
('Rocas y Minerales','Clasificación rocas locales','Formación geológica',8,'Primaria','http://studentsdiscover.org/roc','2024-09-25','2024-12-15'),
('Sistema Solar a Escala','Modelo patio escolar','Distancias relativas',6,'Primaria','http://studentsdiscover.org/sol','2024-10-10','2024-12-05'),
('Microscopía Casera','Microscopio con gota agua','Observar microorganismos',1,'Secundaria','http://studentsdiscover.org/mic','2024-09-05','2024-12-20'),
('Energía Eólica','Turbinas recicladas','Energía renovable',7,'Secundaria','http://studentsdiscover.org/eol','2024-11-01','2025-03-01'),
('Ácidos y Bases','Indicadores naturales','Medir pH',3,'Secundaria','http://studentsdiscover.org/ph','2024-10-15','2025-01-20'),
('Mariposas y Polinizadores','Crianza mariposas','Metamorfosis',1,'Primaria','http://studentsdiscover.org/marip','2024-09-01','2024-12-31'),
('Sonido y Ondas','Instrumentos caseros','Propagación sonido',2,'Primaria','http://studentsdiscover.org/son','2024-10-20','2025-01-15'),
('Huertos Escolares','Cultivo aula','Nutrición y sostenibilidad',1,'Primaria','http://studentsdiscover.org/hue','2024-09-10','2025-06-30'),
('Magnetismo','Electroimanes','Fuerzas magnéticas',2,'Secundaria','http://studentsdiscover.org/mag','2024-11-05','2025-02-28'),
('Biodiversidad Local','Inventario parque','Conservación',9,'Secundaria','http://studentsdiscover.org/bio','2024-09-15','2025-05-01'),
('Luz y Color','Prisma y filtros','Descomponer luz',2,'Primaria','http://studentsdiscover.org/luz','2024-10-01','2024-12-20'),
('Cuerpo Humano','Modelos órganos','Anatomía básica',1,'Primaria','http://studentsdiscover.org/cuerpo','2024-09-20','2024-12-15'),
('Reciclaje y Compost','Compost escolar','Ciclo residuos',11,'Primaria','http://studentsdiscover.org/comp','2024-10-01','2025-06-01'),
('Robótica Reciclada','Robots simples','Introducción robótica',7,'Secundaria','http://studentsdiscover.org/rob','2024-11-10','2025-03-15'),
('Fuerzas y Movimiento','Carros globos','Leyes Newton',2,'Secundaria','http://studentsdiscover.org/fuer','2024-10-05','2025-01-25'),
('Agua Potable','Filtros caseros','Purificación',10,'Secundaria','http://studentsdiscover.org/agp','2024-09-25','2024-12-20'),
('Aves de mi Ciudad','Observación aves','Ornitología',1,'Primaria','http://studentsdiscover.org/aves','2024-09-01','2025-06-30'),
('Paneles Solares','Paneles pequeños','Energía solar',2,'Secundaria','http://studentsdiscover.org/solp','2024-11-01','2025-03-31'),
('Genética con Fresa','Extracción ADN','Visualizar ADN',1,'Secundaria','http://studentsdiscover.org/adn','2024-10-10','2024-12-15'),
('Clima y Tiempo','Estación meteorológica','Variables climáticas',4,'Primaria','http://studentsdiscover.org/cli','2024-09-15','2025-06-30'),
('Insectos Útiles','Trampas insectos','Rol ecológico',12,'Primaria','http://studentsdiscover.org/ins','2024-09-05','2024-12-20'),
('Óptica y Lentes','Telescopios caseros','Refracción',2,'Secundaria','http://studentsdiscover.org/opt','2024-10-20','2025-02-10'),
('Ciencia en la Cocina','Experimentos culinarios','Química alimentos',3,'Primaria','http://studentsdiscover.org/coc','2024-09-10','2024-12-20');


INSERT INTO participante (nombre,institucion,email,id_pais,id_tipo_participante) VALUES
('Ana Martínez','Colegio San José Madrid','ana.m@colegio.es',2,1),('Luis Fernández','Universidad Nacional Bogotá','luis.f@unal.edu.co',4,3),
('Carla Gómez','Secundaria Técnica 25 CDMX','carla.g@tec25.mx',3,2),('Diego Ruiz','Instituto Darwin Bs As','diego.r@darwin.ar',5,1),
('Priya Sharma','Delhi Public School','priya.s@dps.in',7,1),('James Wilson','Cambridge University','james.w@cam.ac.uk',6,3),
('Mariana Silva','Escola Municipal Rio','mariana.s@rio.br',8,2),('Emma Tremblay','Toronto District','emma.t@tdsb.ca',9,1),
('Liam Brown','Sydney Grammar','liam.b@sydney.edu.au',10,1),('Sofía Herrera','Colegio Santa María Lima','sofia.h@santamaria.pe',4,1),
('Mateo Vargas','Uniandes Bogotá','mateo.v@uniandes.edu.co',4,3),('Valeria Castro','Liceo Boston Santiago','valeria.c@boston.cl',5,2),
('Alejandro Torres','IES La Laguna Tenerife','alejandro.t@ies.es',2,1),('Lucía Navarro','Colegio Alemán Quito','lucia.n@aleman.ec',4,2),
('Pablo Ortiz','UNAM Ciencias','pablo.o@unam.mx',3,3),('Isabella Rossi','Istituto Tecnico Roma','isabella.r@tec.it',6,1),
('Noah García','High School California','noah.g@hs.us',1,1),('Olivia Pérez','Colegio Montserrat Barcelona','olivia.p@montserrat.es',2,2),
('Ethan Kim','Seoul Science High','ethan.k@ssh.kr',7,1),('Mia López','USP São Paulo','mia.l@usp.br',8,3),
('Lucas Morales','Colegio San Ignacio Asunción','lucas.m@sanignacio.py',5,1),('Amelia Clark','Melbourne Girls Grammar','amelia.c@mgg.au',10,1),
('Daniel Rivera','Instituto Nacional Panamá','daniel.r@in.edu.pa',9,2),('Zoe Martínez','Lycée Français Madrid','zoe.m@lycee.es',2,1),
('Samuel Díaz','UAM CDMX','samuel.d@uam.mx',3,3),('Luna Castillo','Nueva Granada Bogotá','luna.c@nuevagranada.edu.co',4,2),
('Gabriel Soto','IES El Greco Toledo','gabriel.s@elgreco.es',2,1),('Victoria Muñoz','San Patricio Lisboa','victoria.m@sanpatricio.pt',6,1),
('Leonardo Ramos','UBA Buenos Aires','leonardo.r@uba.ar',5,3),('Camila Vega','Colegio Williams Monterrey','camila.v@williams.mx',3,2);

INSERT INTO proyecto_participante (id_proyecto,id_participante,rol) VALUES
(1,1,'Líder'),(2,2,'Investigador'),(3,3,'Coordinadora'),(4,4,'Estudiante'),(5,5,'Apoyo'),
(6,6,'Investigador'),(7,7,'Profesor'),(8,8,'Estudiante'),(9,9,'Estudiante'),(10,10,'Estudiante'),
(11,11,'Investigador'),(12,12,'Profesora'),(13,13,'Estudiante'),(14,14,'Profesor'),(15,15,'Investigador'),
(16,16,'Estudiante'),(17,17,'Estudiante'),(18,18,'Coordinadora'),(19,19,'Estudiante'),(20,20,'Investigadora'),
(21,21,'Estudiante'),(22,22,'Estudiante'),(23,23,'Profesor'),(24,24,'Estudiante'),(25,25,'Investigador'),
(26,26,'Coordinadora'),(27,27,'Estudiante'),(28,28,'Estudiante'),(29,29,'Investigador'),(30,30,'Profesora');

INSERT INTO actividad (id_proyecto,titulo,descripcion,tipo_actividad,duracion_estimada) VALUES
(1,'Salida al parque','Observación especies','Campo','3h'),(2,'Construir palanca','Regla y fulcro','Experimental','1.5h'),
(3,'Montar acuario','Organismos marinos','Práctica','4h'),(4,'Volcán','Vinagre+bicarbonato','Demo','30min'),
(5,'Ciclo agua botella','Calor y frío','Experimental','1h'),(6,'Luz vs oscuridad','Plantas','Investigación','2 semanas'),
(7,'Circuito serie/paralelo','Bombillas','Práctica','2h'),(8,'Clasificar rocas','Dureza/color','Clasificación','2h'),
(9,'Modelo solar patio','Distancias','Construcción','3h'),(10,'Microscopio gota','Protozoarios','Observación','1.5h'),
(11,'Turbina reciclada','Medir voltaje','Ingeniería','5h'),(12,'Repollo morado','pH','Experimental','1h'),
(13,'Crianza mariposas','Oruga a adulta','Crianza','4 semanas'),(14,'Instrumentos caseros','Sonido','Construcción','2h'),
(15,'Huerto aula','Siembra','Agricultura','3 meses'),(16,'Electroimán','Clips','Experimental','1h'),
(17,'Inventario parque','Transecto','Campo','4h'),(18,'Prisma','Arcoíris','Óptica','45min'),
(19,'Corazón botellas','Circulación','Construcción','2h'),(20,'Compost botella','Descomposición','Experimental','6 semanas'),
(21,'Robot reciclado','Línea','Robótica','8h'),(22,'Carros globos','Newton','Carreras','2h'),
(23,'Filtro carbón','Agua sucia','Química','2h'),(24,'Diario aves','Fotos','Campo','continuo'),
(25,'Panel solar','Corriente','Energía','3h'),(26,'ADN fresa','Alcohol','Biotec','1h'),
(27,'Estación meteo','Registro','Medición','continuo'),(28,'Trampa insectos','Identificación','Campo','2h'),
(29,'Telescopio cartón','Luna','Construcción','3h'),(30,'Fermentación','Levadura','Bioquímica','1.5h');

INSERT INTO requisito (id_proyecto,descripcion,obligatorio) VALUES
(1,'Parque cercano',1),(2,'Reglas y objetos',1),(3,'Pecera grande',1),(4,'Vinagre y bicarbonato',1),
(5,'Botellas y calor',1),(6,'Plantas y bolsas',1),(7,'Pilas y cables',1),(8,'Muestras rocas',1),
(9,'Cinta métrica',1),(10,'Lentes aumento',1),(11,'Motor y multímetro',1),(12,'Repollo morado',1),
(13,'Orugas vivas',1),(14,'Tubos y semillas',1),(15,'Tierra y macetas',1),(16,'Clavo y pila',1),
(17,'Binoculares',1),(18,'Prisma o CD',1),(19,'Botellas colorante',1),(20,'Restos orgánicos',1),
(21,'Kit robótica',1),(22,'Carros y globos',1),(23,'Carbón y arena',1),(24,'Cámara celular',0),
(25,'Células solares',1),(26,'Fresas y alcohol',1),(27,'Termómetro',1),(28,'Red insectos',0),
(29,'Tubos cartón',1),(30,'Levadura azúcar',1);