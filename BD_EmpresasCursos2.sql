-- =====================================================
-- BDCursosEmpresas - Script de Creacion (v3)
-- Trabajo Practico Integrador - Grupo 7
-- Integrantes: Joel Almiron, Brian | Mariel Alejandra De Grazia
-- =====================================================

USE MASTER;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'BDCursosEmpresas')
BEGIN
    ALTER DATABASE BDCursosEmpresas SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BDCursosEmpresas;
END
GO

CREATE DATABASE BDCursosEmpresas
COLLATE Latin1_General_CI_AI;
GO

USE BDCursosEmpresas;
GO

-- =====================================================
-- Tabla: TiposSuscripcion
-- Catalogo de los tipos de suscripcion disponibles.
-- =====================================================
CREATE TABLE TiposSuscripcion (
    IDTipoSuscripcion INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL,
    Detalle VARCHAR(100) NOT NULL,
    Duracion INT NULL,          -- en dias. NULL = sin vencimiento
    Precio MONEY NOT NULL
);
GO

-- =====================================================
-- Tabla: Usuario
-- =====================================================
CREATE TABLE Usuario (
    IDUsuario INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    mail VARCHAR(100) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    FechaDeInscripcion DATE DEFAULT GETDATE()
);
GO

-- =====================================================
-- Tabla: Empresas
-- Registra las empresas que utilizan la plataforma.
-- ** Ya no tiene IDRol (Opcion A: ahora Roles depende de Empresas) **
-- =====================================================
CREATE TABLE Empresas (
    IDEmpresa INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(255) NOT NULL,
    sector VARCHAR(100),
    descripcion VARCHAR(255)
);
GO

-- =====================================================
-- Tabla: Suscripcion
-- Registra las suscripciones activas e historicas de cada usuario.
-- =====================================================
CREATE TABLE Suscripcion (
    IDSuscripcion INT PRIMARY KEY IDENTITY(1,1),
    IDTipoSuscripcion INT NOT NULL,
    IDUsuario INT NOT NULL,
    FechaInicio DATE DEFAULT GETDATE(),
    FechaFinalizacion DATE NULL,
    Activa BIT DEFAULT 0,
    CONSTRAINT FK_Suscripcion_TipoSuscripcion FOREIGN KEY (IDTipoSuscripcion) REFERENCES TiposSuscripcion(IDTipoSuscripcion),
    CONSTRAINT FK_Suscripcion_Usuario FOREIGN KEY (IDUsuario) REFERENCES Usuario(IDUsuario)
);
GO

-- =====================================================
-- Tabla: Instructor   (antes "Empleados")
-- Empleados de cada empresa que dictan cursos.
-- =====================================================
CREATE TABLE Instructor (
    IDInstructor INT PRIMARY KEY IDENTITY(1,1),
    IDEmpresa INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    mail VARCHAR(100),
    puesto VARCHAR(50),     -- ej: 'Instructor', 'Coordinador'
    CONSTRAINT FK_Instructor_Empresas FOREIGN KEY (IDEmpresa) REFERENCES Empresas(IDEmpresa)
);
GO

-- =====================================================
-- Tabla: Roles   ** Opcion A: ahora depende de Empresas **
-- Roles laborales que ofrece cada empresa (una empresa puede
-- tener varios roles: QA, Front-End, Back-End, etc).
-- =====================================================
CREATE TABLE Roles (
    IDRol INT PRIMARY KEY IDENTITY(1,1),
    IDEmpresa INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    CONSTRAINT FK_Roles_Empresas FOREIGN KEY (IDEmpresa) REFERENCES Empresas(IDEmpresa)
);
GO

-- =====================================================
-- Tabla: Curso   ** Opcion A: ahora depende de Roles, no de Empresas **
-- La empresa del curso queda implicita via Curso -> Roles -> Empresas.
-- =====================================================
CREATE TABLE Curso (
    IDCurso INT PRIMARY KEY IDENTITY(1,1),
    IDRol INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(250),
    DuracionHoras INT NULL,
    CONSTRAINT FK_Curso_Roles FOREIGN KEY (IDRol) REFERENCES Roles(IDRol)
);
GO

-- =====================================================
-- Tabla: CursoInstructor
-- Relacion N a N: un curso puede tener mas de un instructor,
-- y un instructor puede dar mas de un curso.
-- =====================================================
CREATE TABLE CursoInstructor (
    IDCurso INT NOT NULL,
    IDInstructor INT NOT NULL,
    CONSTRAINT PK_CursoInstructor PRIMARY KEY (IDCurso, IDInstructor),
    CONSTRAINT FK_CursoInstructor_Curso FOREIGN KEY (IDCurso) REFERENCES Curso(IDCurso),
    CONSTRAINT FK_CursoInstructor_Instructor FOREIGN KEY (IDInstructor) REFERENCES Instructor(IDInstructor)
);
GO

-- =====================================================
-- Tabla: Archivo
-- Catalogo de materiales de estudio del curso (solo catalogo,
-- sin mezclar progreso individual del usuario).
-- =====================================================
CREATE TABLE Archivo (
    IDArchivo INT PRIMARY KEY IDENTITY(1,1),
    IDCurso INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    formato VARCHAR(20) NOT NULL,      -- ej: 'video', 'pdf'
    tamaño INT NULL,                   -- en KB. NULL si es solo un link externo
    link VARCHAR(255) NULL,            -- URL externa (ej. YouTube) del recurso
    CONSTRAINT FK_Archivo_Curso FOREIGN KEY (IDCurso) REFERENCES Curso(IDCurso)
);
GO

-- =====================================================
-- Tabla: ProgresoArchivo
-- Avance individual de cada usuario sobre los materiales.
-- =====================================================
CREATE TABLE ProgresoArchivo (
    IDProgreso INT PRIMARY KEY IDENTITY(1,1),
    IDUsuario INT NOT NULL,
    IDArchivo INT NOT NULL,
    Completado BIT NOT NULL DEFAULT 0,
    FechaCompletado DATE NULL,
    CONSTRAINT UQ_ProgresoArchivo UNIQUE (IDUsuario, IDArchivo),
    CONSTRAINT FK_ProgresoArchivo_Usuario FOREIGN KEY (IDUsuario) REFERENCES Usuario(IDUsuario),
    CONSTRAINT FK_ProgresoArchivo_Archivo FOREIGN KEY (IDArchivo) REFERENCES Archivo(IDArchivo)
);
GO

-- =====================================================
-- Tabla: Inscripcion
-- Registra la inscripcion de un usuario a un curso.
-- Ya no tiene "Completado": esa finalizacion queda implicita
-- en la existencia de un Certificado para ese usuario+curso.
-- =====================================================
CREATE TABLE Inscripcion (
    IDInscripcion INT PRIMARY KEY IDENTITY(1,1),
    IDUsuario INT NOT NULL,
    IDCurso INT NOT NULL,
    FechaInscripcion DATE DEFAULT GETDATE(),
    CONSTRAINT UQ_Inscripcion UNIQUE (IDUsuario, IDCurso),
    CONSTRAINT FK_Inscripcion_Usuario FOREIGN KEY (IDUsuario) REFERENCES Usuario(IDUsuario),
    CONSTRAINT FK_Inscripcion_Curso FOREIGN KEY (IDCurso) REFERENCES Curso(IDCurso)
);
GO

-- =====================================================
-- Tabla: Evaluacion
-- =====================================================
CREATE TABLE Evaluacion (
    IDEvaluacion INT PRIMARY KEY IDENTITY(1,1),
    IDCurso INT NOT NULL,
    Titulo VARCHAR(50),
    PuntajeMinimo INT,      -- nota minima para aprobar
    CONSTRAINT FK_Evaluacion_Curso FOREIGN KEY (IDCurso) REFERENCES Curso(IDCurso)
);
GO

-- =====================================================
-- Tabla: ResultadoEvaluacion
-- Registra el resultado obtenido por cada usuario en cada evaluacion.
-- =====================================================
CREATE TABLE ResultadoEvaluacion (
    IDResultado INT PRIMARY KEY IDENTITY(1,1),
    IDEvaluacion INT NOT NULL,
    IDUsuario INT NOT NULL,
    NotaObtenida INT,
    Aprobado BIT DEFAULT 0,
    CONSTRAINT UQ_ResultadoEvaluacion UNIQUE (IDEvaluacion, IDUsuario),
    CONSTRAINT FK_ResultadoEvaluacion_Evaluacion FOREIGN KEY (IDEvaluacion) REFERENCES Evaluacion(IDEvaluacion),
    CONSTRAINT FK_ResultadoEvaluacion_Usuario FOREIGN KEY (IDUsuario) REFERENCES Usuario(IDUsuario)
);
GO

-- =====================================================
-- Tabla: Certificado   (antes "Certificados", plural)
-- Depende unicamente de ResultadoEvaluacion (cumple 3FN):
--   IDUsuario: Certificado -> ResultadoEvaluacion -> IDUsuario
--   IDCurso:   Certificado -> ResultadoEvaluacion -> Evaluacion -> IDCurso
-- =====================================================
CREATE TABLE Certificado (
    IDCertificado INT PRIMARY KEY IDENTITY(1,1),
    IDResultado INT NOT NULL UNIQUE,
    FechaDeEmision DATE DEFAULT GETDATE(),
    CONSTRAINT FK_Certificado_ResultadoEvaluacion FOREIGN KEY (IDResultado) REFERENCES ResultadoEvaluacion(IDResultado)
);
GO

-- =====================================================
-- Tabla: Resena   (documentacion: "Reseña" - sin tilde en SQL
-- por compatibilidad de encoding)
-- Solo puede resenar un curso quien ya tiene Certificado.
-- =====================================================
CREATE TABLE Resena (
    IDResena INT PRIMARY KEY IDENTITY(1,1),
    IDCertificado INT NOT NULL UNIQUE,
    Comentario VARCHAR(500),
    Puntuacion INT,        -- escala 1 a 5
    Fecha DATE DEFAULT GETDATE(),
    CONSTRAINT FK_Resena_Certificado FOREIGN KEY (IDCertificado) REFERENCES Certificado(IDCertificado),
    CONSTRAINT CK_Resena_Puntuacion CHECK (Puntuacion BETWEEN 1 AND 5)
);
GO
