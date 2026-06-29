CREATE TABLE Curso (
    IDCurso INT PRIMARY KEY IDENTITY(1,1),
    IDRol INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(250),
    DuracionHoras INT NULL,
    CONSTRAINT FK_Curso_Roles FOREIGN KEY (IDRol) REFERENCES Roles(IDRol)
);
GO
CREATE TABLE CursoInstructor (
    IDCurso INT NOT NULL,
    IDInstructor INT NOT NULL,
    CONSTRAINT PK_CursoInstructor PRIMARY KEY (IDCurso, IDInstructor),
    CONSTRAINT FK_CursoInstructor_Curso FOREIGN KEY (IDCurso) REFERENCES Curso(IDCurso),
    CONSTRAINT FK_CursoInstructor_Instructor FOREIGN KEY (IDInstructor) REFERENCES Instructor(IDInstructor)
);
GO
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
CREATE TABLE Evaluacion (
    IDEvaluacion INT PRIMARY KEY IDENTITY(1,1),
    IDCurso INT NOT NULL,
    Titulo VARCHAR(50),
    PuntajeMinimo INT,      -- nota minima para aprobar
    CONSTRAINT FK_Evaluacion_Curso FOREIGN KEY (IDCurso) REFERENCES Curso(IDCurso)
);
GO
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
CREATE TABLE Certificado (
    IDCertificado INT PRIMARY KEY IDENTITY(1,1),
    IDResultado INT NOT NULL UNIQUE,
    FechaDeEmision DATE DEFAULT GETDATE(),
    CONSTRAINT FK_Certificado_ResultadoEvaluacion FOREIGN KEY (IDResultado) REFERENCES ResultadoEvaluacion(IDResultado)
);
GO
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
