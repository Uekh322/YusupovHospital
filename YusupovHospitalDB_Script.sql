USE [master]
GO
CREATE DATABASE [HospitalBD]
GO
USE [HospitalBD]
GO
/****** Объект:  User [Registrar_User]    Дата создания скрипта: 13.10.2026 18:05:49 ******/
CREATE USER [Registrar_User] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Объект:  User [Doctor_User]    Дата создания скрипта: 13.10.2026 18:05:49 ******/
CREATE USER [Doctor_User] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Объект:  User [ChiefDoctor_User]    Дата создания скрипта: 13.10.2026 18:05:49 ******/
CREATE USER [ChiefDoctor_User] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Объект:  DatabaseRole [RegistrarRole]    Дата создания скрипта: 13.10.2026 18:05:49 ******/
CREATE ROLE [RegistrarRole]
GO
/****** Объект:  DatabaseRole [DoctorRole]    Дата создания скрипта: 13.10.2026 18:05:49 ******/
CREATE ROLE [DoctorRole]
GO
/****** Объект:  DatabaseRole [ChiefDoctorRole]    Дата создания скрипта: 13.10.2026 18:05:49 ******/
CREATE ROLE [ChiefDoctorRole]
GO
ALTER ROLE [RegistrarRole] ADD MEMBER [Registrar_User]
GO
ALTER ROLE [DoctorRole] ADD MEMBER [Doctor_User]
GO
ALTER ROLE [ChiefDoctorRole] ADD MEMBER [ChiefDoctor_User]
GO
/****** Объект:  Table [dbo].[Departments]    Дата создания скрипта: 13.10.2026 18:05:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Departments](
	[Id_отделения] [int] IDENTITY(1,1) NOT NULL,
	[Название] [nvarchar](100) NOT NULL,
	[Этаж] [int] NOT NULL,
	[Номера_комнат] [nvarchar](255) NOT NULL,
	[Id_заведующего] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[Id_отделения] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Объект:  Table [dbo].[Doctors]    Дата создания скрипта: 13.10.2026 18:05:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Doctors](
	[Id_врача] [int] IDENTITY(1,1) NOT NULL,
	[Фамилия] [nvarchar](100) NOT NULL,
	[Имя] [nvarchar](100) NOT NULL,
	[Отчество] [nvarchar](100) NULL,
	[Должность] [nvarchar](100) NOT NULL,
	[Дата_начала_работы] [date] NOT NULL,
	[Стаж]  AS (datediff(year,[Дата_начала_работы],getdate())),
	[Научное_звание] [nvarchar](100) NULL,
	[Адрес] [nvarchar](255) NOT NULL,
	[Id_отделения] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[Id_врача] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Объект:  Table [dbo].[MedicalHistories]    Дата создания скрипта: 13.10.2026 18:05:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicalHistories](
	[Id_истории] [int] IDENTITY(1,1) NOT NULL,
	[Id_пациента] [int] NOT NULL,
	[Id_врача] [int] NOT NULL,
	[Диагноз] [nvarchar](500) NOT NULL,
	[Дата_заболевания] [date] NOT NULL,
	[Дата_вылечивания] [date] NULL,
	[Вид_лечения] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED
(
	[Id_истории] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Объект:  Table [dbo].[Patients]    Дата создания скрипта: 13.10.2026 18:05:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Patients](
	[Id_пациента] [int] IDENTITY(1,1) NOT NULL,
	[Фамилия] [nvarchar](100) NOT NULL,
	[Имя] [nvarchar](100) NOT NULL,
	[Отчество] [nvarchar](100) NULL,
	[Дата_рождения] [date] NOT NULL,
	[Возраст]  AS (datediff(year,[Дата_рождения],getdate())),
	[Адрес] [nvarchar](255) NOT NULL,
	[Город] [nvarchar](100) NOT NULL,
	[Пол] [char](1) NOT NULL,
PRIMARY KEY CLUSTERED
(
	[Id_пациента] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Объект:  Table [dbo].[TreatmentSheets]    Дата создания скрипта: 13.10.2026 18:05:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TreatmentSheets](
	[Id_записи] [int] IDENTITY(1,1) NOT NULL,
	[Id_истории] [int] NOT NULL,
	[Дата_лечения] [date] NOT NULL,
	[Лекарства] [nvarchar](500) NOT NULL,
	[Температура] [decimal](3, 1) NOT NULL,
	[Давление] [nvarchar](20) NOT NULL,
	[Состояние] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED
(
	[Id_записи] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Объект:  View [dbo].[View_DepartmentsTotalExperience]    Дата создания скрипта: 13.10.2026 18:05:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[View_DepartmentsTotalExperience] AS
SELECT
    dep.Название AS Отделение,
    SUM(d.Стаж) AS Общий_стаж
FROM Doctors d
INNER JOIN Departments dep ON d.Id_отделения = dep.Id_отделения
GROUP BY dep.Название;
GO
/****** Объект:  View [dbo].[View_DoctorsStats]    Дата создания скрипта: 13.10.2026 18:05:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[View_DoctorsStats] AS
SELECT
    d.Фамилия,
    d.Имя,
    COUNT(mh.Id_истории) AS Количество_историй
FROM Doctors d
LEFT JOIN MedicalHistories mh ON d.Id_врача = mh.Id_врача
GROUP BY d.Id_врача, d.Фамилия, d.Имя;
GO
/****** Объект:  View [dbo].[View_PatientsWithoutHistories]    Дата создания скрипта: 13.10.2026 18:05:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[View_PatientsWithoutHistories] AS
SELECT
    p.Id_пациента,
    p.Фамилия,
    p.Имя,
    p.Город
FROM Patients p
LEFT JOIN MedicalHistories mh ON p.Id_пациента = mh.Id_пациента
WHERE mh.Id_истории IS NULL;
GO
/****** Объект:  View [dbo].[View_TreatmentDetails]    Дата создания скрипта: 13.10.2026 18:05:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =====================================================
-- ШАГ 10: ПРЕДСТАВЛЕНИЯ
-- =====================================================
CREATE VIEW [dbo].[View_TreatmentDetails] AS
SELECT
    ts.Дата_лечения,
    p.Фамилия AS Пациент,
    p.Имя,
    mh.Диагноз,
    ts.Температура,
    ts.Давление,
    ts.Состояние
FROM TreatmentSheets ts
INNER JOIN MedicalHistories mh ON ts.Id_истории = mh.Id_истории
INNER JOIN Patients p ON mh.Id_пациента = p.Id_пациента;
GO
SET IDENTITY_INSERT [dbo].[Departments] ON

INSERT [dbo].[Departments] ([Id_отделения], [Название], [Этаж], [Номера_комнат], [Id_заведующего]) VALUES (1, N'Хирургия', 3, N'301-315', 1)
INSERT [dbo].[Departments] ([Id_отделения], [Название], [Этаж], [Номера_комнат], [Id_заведующего]) VALUES (2, N'Терапия', 2, N'201-220', 2)
INSERT [dbo].[Departments] ([Id_отделения], [Название], [Этаж], [Номера_комнат], [Id_заведующего]) VALUES (3, N'Кардиология', 4, N'401-410', 3)
INSERT [dbo].[Departments] ([Id_отделения], [Название], [Этаж], [Номера_комнат], [Id_заведующего]) VALUES (4, N'Неврология', 5, N'501-512', 4)
INSERT [dbo].[Departments] ([Id_отделения], [Название], [Этаж], [Номера_комнат], [Id_заведующего]) VALUES (5, N'Травматология', 1, N'101-115', 5)
SET IDENTITY_INSERT [dbo].[Departments] OFF
GO
SET IDENTITY_INSERT [dbo].[Doctors] ON

INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (1, N'Иванов', N'Иван', N'Иванович', N'Заведующий отделением', CAST(N'2010-03-15' AS Date), N'Профессор', N'ул. Ленина, 10', 1)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (2, N'Петрова', N'Анна', N'Сергеевна', N'Заведующий отделением', CAST(N'2012-07-20' AS Date), N'Доцент', N'ул. Гагарина, 25', 2)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (3, N'Сидоров', N'Алексей', N'Владимирович', N'Заведующий отделением', CAST(N'2011-11-01' AS Date), N'Профессор', N'пр. Октября, 8', 3)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (4, N'Кузнецова', N'Елена', N'Петровна', N'Заведующий отделением', CAST(N'2013-05-10' AS Date), N'Доцент', N'ул. Советская, 15', 4)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (5, N'Смирнов', N'Дмитрий', N'Николаевич', N'Заведующий отделением', CAST(N'2009-09-25' AS Date), N'Профессор', N'ул. Кирова, 42', 5)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (6, N'Волкова', N'Мария', N'Александровна', N'Врач-хирург', CAST(N'2015-02-10' AS Date), NULL, N'ул. Пушкина, 3', 1)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (7, N'Морозов', N'Андрей', N'Викторович', N'Врач-терапевт', CAST(N'2016-06-15' AS Date), NULL, N'ул. Лермонтова, 7', 2)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (8, N'Новикова', N'Татьяна', N'Игоревна', N'Врач-кардиолог', CAST(N'2017-03-20' AS Date), NULL, N'ул. Чехова, 12', 3)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (9, N'Козлов', N'Сергей', N'Михайлович', N'Врач-невролог', CAST(N'2014-11-05' AS Date), NULL, N'ул. Мира, 19', 4)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (10, N'Лебедева', N'Ольга', N'Владимировна', N'Врач-травматолог', CAST(N'2018-01-30' AS Date), NULL, N'ул. Дружбы, 5', 5)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (11, N'Соколов', N'Павел', N'Андреевич', N'Врач-хирург', CAST(N'2019-04-12' AS Date), NULL, N'ул. Строителей, 9', 1)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (12, N'Михайлова', N'Ирина', N'Сергеевна', N'Врач-терапевт', CAST(N'2015-08-22' AS Date), NULL, N'ул. Парковая, 14', 2)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (13, N'Федоров', N'Николай', N'Петрович', N'Врач-кардиолог', CAST(N'2016-12-01' AS Date), NULL, N'ул. Лесная, 23', 3)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (14, N'Егорова', N'Светлана', N'Алексеевна', N'Врач-невролог', CAST(N'2017-07-18' AS Date), NULL, N'ул. Речная, 31', 4)
INSERT [dbo].[Doctors] ([Id_врача], [Фамилия], [Имя], [Отчество], [Должность], [Дата_начала_работы], [Научное_звание], [Адрес], [Id_отделения]) VALUES (15, N'Андреев', N'Владимир', N'Борисович', N'Врач-травматолог', CAST(N'2020-09-05' AS Date), NULL, N'ул. Зеленая, 6', 5)
SET IDENTITY_INSERT [dbo].[Doctors] OFF
GO
SET IDENTITY_INSERT [dbo].[MedicalHistories] ON

INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (1, 1, 6, N'Аппендицит острый', CAST(N'2024-01-15' AS Date), CAST(N'2024-01-25' AS Date), N'Стационарно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (2, 2, 7, N'Грипп тяжелой формы', CAST(N'2024-01-20' AS Date), CAST(N'2024-02-05' AS Date), N'Амбулаторно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (3, 3, 8, N'Ишемическая болезнь сердца', CAST(N'2024-02-01' AS Date), CAST(N'2024-02-20' AS Date), N'Стационарно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (4, 4, 9, N'Мигрень', CAST(N'2024-02-10' AS Date), CAST(N'2024-02-18' AS Date), N'Амбулаторно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (5, 5, 10, N'Перелом руки', CAST(N'2024-02-15' AS Date), CAST(N'2024-03-10' AS Date), N'Стационарно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (6, 6, 11, N'Холецистит', CAST(N'2024-03-01' AS Date), CAST(N'2024-03-20' AS Date), N'Стационарно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (7, 7, 12, N'Бронхит', CAST(N'2024-03-05' AS Date), CAST(N'2024-03-15' AS Date), N'Амбулаторно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (8, 8, 13, N'Гипертония', CAST(N'2024-03-10' AS Date), NULL, N'Амбулаторно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (9, 9, 14, N'Радикулит', CAST(N'2024-03-12' AS Date), CAST(N'2024-03-28' AS Date), N'Стационарно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (10, 10, 15, N'Ушиб голени', CAST(N'2024-03-15' AS Date), CAST(N'2024-03-25' AS Date), N'Амбулаторно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (11, 11, 6, N'Грыжа', CAST(N'2024-04-01' AS Date), CAST(N'2024-04-15' AS Date), N'Стационарно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (12, 12, 7, N'ОРВИ', CAST(N'2024-04-03' AS Date), CAST(N'2024-04-10' AS Date), N'Амбулаторно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (13, 13, 8, N'Стенокардия', CAST(N'2024-04-05' AS Date), NULL, N'Амбулаторно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (14, 14, 9, N'Невралгия', CAST(N'2024-04-08' AS Date), CAST(N'2024-04-20' AS Date), N'Амбулаторно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (15, 15, 10, N'Перелом ноги', CAST(N'2024-04-10' AS Date), CAST(N'2024-05-05' AS Date), N'Стационарно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (16, 16, 11, N'Желчнокаменная болезнь', CAST(N'2024-04-12' AS Date), CAST(N'2024-05-01' AS Date), N'Стационарно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (17, 17, 12, N'Пневмония', CAST(N'2024-04-15' AS Date), CAST(N'2024-05-10' AS Date), N'Стационарно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (18, 18, 13, N'Аритмия', CAST(N'2024-04-18' AS Date), NULL, N'Амбулаторно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (19, 19, 14, N'Остеохондроз', CAST(N'2024-04-20' AS Date), CAST(N'2024-05-05' AS Date), N'Амбулаторно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (20, 20, 15, N'Вывих плеча', CAST(N'2024-04-22' AS Date), CAST(N'2024-05-01' AS Date), N'Стационарно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (21, 1, 6, N'Панкреатит', CAST(N'2024-05-01' AS Date), CAST(N'2024-05-20' AS Date), N'Стационарно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (22, 999, 6, N'Орфанное заболевание', CAST(N'2025-01-10' AS Date), NULL, N'Стационарно')
INSERT [dbo].[MedicalHistories] ([Id_истории], [Id_пациента], [Id_врача], [Диагноз], [Дата_заболевания], [Дата_вылечивания], [Вид_лечения]) VALUES (23, 888, 7, N'Синдром неизвестной этиологии', CAST(N'2025-02-15' AS Date), CAST(N'2025-03-01' AS Date), N'Амбулаторно')
SET IDENTITY_INSERT [dbo].[MedicalHistories] OFF
GO
SET IDENTITY_INSERT [dbo].[Patients] ON

INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (1, N'Александров', N'Сергей', N'Петрович', CAST(N'1985-03-12' AS Date), N'ул. Мира, 15', N'Уфа', N'М')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (2, N'Борисова', N'Анна', N'Владимировна', CAST(N'1990-07-25' AS Date), N'ул. Ленина, 42', N'Уфа', N'Ж')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (3, N'Васильев', N'Дмитрий', N'Иванович', CAST(N'1978-11-05' AS Date), N'пр. Октября, 8', N'Уфа', N'М')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (4, N'Григорьева', N'Екатерина', N'Алексеевна', CAST(N'1995-02-18' AS Date), N'ул. Советская, 23', N'Уфа', N'Ж')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (5, N'Дмитриев', N'Алексей', N'Сергеевич', CAST(N'1982-09-30' AS Date), N'ул. Гагарина, 7', N'Уфа', N'М')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (6, N'Егорова', N'Ольга', N'Николаевна', CAST(N'1988-04-22' AS Date), N'ул. Кирова, 56', N'Уфа', N'Ж')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (7, N'Жуков', N'Игорь', N'Павлович', CAST(N'1975-12-10' AS Date), N'ул. Пушкина, 34', N'Уфа', N'М')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (8, N'Зайцева', N'Татьяна', N'Михайловна', CAST(N'1992-06-14' AS Date), N'ул. Лермонтова, 9', N'Уфа', N'Ж')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (9, N'Иванов', N'Максим', N'Андреевич', CAST(N'1980-08-19' AS Date), N'ул. Чехова, 17', N'Уфа', N'М')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (10, N'Кузьмина', N'Наталья', N'Валерьевна', CAST(N'1987-01-27' AS Date), N'ул. Дружбы, 22', N'Уфа', N'Ж')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (11, N'Лазарев', N'Владимир', N'Борисович', CAST(N'1993-03-05' AS Date), N'ул. Строителей, 11', N'Уфа', N'М')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (12, N'Максимова', N'Ирина', N'Сергеевна', CAST(N'1984-10-15' AS Date), N'ул. Парковая, 45', N'Уфа', N'Ж')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (13, N'Никитин', N'Артем', N'Витальевич', CAST(N'1991-07-08' AS Date), N'ул. Лесная, 3', N'Уфа', N'М')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (14, N'Орлова', N'Светлана', N'Петровна', CAST(N'1986-09-20' AS Date), N'ул. Речная, 29', N'Уфа', N'Ж')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (15, N'Павлов', N'Роман', N'Игоревич', CAST(N'1979-05-30' AS Date), N'ул. Зеленая, 18', N'Уфа', N'М')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (16, N'Романова', N'Юлия', N'Александровна', CAST(N'1994-11-11' AS Date), N'ул. Цветочная, 7', N'Уфа', N'Ж')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (17, N'Сергеев', N'Константин', N'Дмитриевич', CAST(N'1983-12-25' AS Date), N'ул. Школьная, 33', N'Уфа', N'М')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (18, N'Тимофеева', N'Анастасия', N'Владимировна', CAST(N'1996-04-03' AS Date), N'ул. Садовая, 12', N'Уфа', N'Ж')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (19, N'Устинов', N'Григорий', N'Николаевич', CAST(N'1981-06-17' AS Date), N'ул. Молодежная, 27', N'Уфа', N'М')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (20, N'Филиппова', N'Людмила', N'Евгеньевна', CAST(N'1989-08-29' AS Date), N'ул. Вокзальная, 41', N'Уфа', N'Ж')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (21, N'Абдуллин', N'Марат', N'Фаритович', CAST(N'1995-04-10' AS Date), N'ул. Комсомольская, 15', N'Уфа', N'М')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (22, N'Гареева', N'Алина', N'Ринатовна', CAST(N'2000-07-22' AS Date), N'ул. Цюрупы, 8', N'Уфа', N'Ж')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (23, N'Хакимов', N'Булат', N'Рашидович', CAST(N'1988-12-05' AS Date), N'пр. Октября, 120', N'Уфа', N'М')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (24, N'Мусина', N'Диана', N'Флюровна', CAST(N'1992-03-18' AS Date), N'ул. Менделеева, 33', N'Уфа', N'Ж')
INSERT [dbo].[Patients] ([Id_пациента], [Фамилия], [Имя], [Отчество], [Дата_рождения], [Адрес], [Город], [Пол]) VALUES (25, N'Каримов', N'Тимур', N'Ильдарович', CAST(N'2005-09-30' AS Date), N'ул. Айская, 7', N'Уфа', N'М')
SET IDENTITY_INSERT [dbo].[Patients] OFF
GO
SET IDENTITY_INSERT [dbo].[TreatmentSheets] ON

INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (1, 1, CAST(N'2024-01-16' AS Date), N'Амоксициллин, Ибупрофен', CAST(38.2 AS Decimal(3, 1)), N'120/80', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (2, 1, CAST(N'2024-01-17' AS Date), N'Амоксициллин', CAST(37.5 AS Decimal(3, 1)), N'118/75', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (3, 1, CAST(N'2024-01-18' AS Date), N'Амоксициллин', CAST(36.8 AS Decimal(3, 1)), N'115/70', N'Удовлетворительное')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (4, 2, CAST(N'2024-01-21' AS Date), N'Парацетамол, Арбидол', CAST(38.5 AS Decimal(3, 1)), N'125/85', N'Тяжелое')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (5, 2, CAST(N'2024-01-22' AS Date), N'Парацетамол', CAST(37.8 AS Decimal(3, 1)), N'120/80', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (6, 2, CAST(N'2024-01-23' AS Date), N'Арбидол', CAST(36.9 AS Decimal(3, 1)), N'118/78', N'Удовлетворительное')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (7, 3, CAST(N'2024-02-02' AS Date), N'Аспирин, Нитроглицерин', CAST(36.6 AS Decimal(3, 1)), N'140/90', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (8, 3, CAST(N'2024-02-03' AS Date), N'Аспирин', CAST(36.5 AS Decimal(3, 1)), N'135/85', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (9, 4, CAST(N'2024-02-11' AS Date), N'Сумамигрен', CAST(36.6 AS Decimal(3, 1)), N'110/70', N'Удовлетворительное')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (10, 4, CAST(N'2024-02-12' AS Date), N'Сумамигрен', CAST(36.6 AS Decimal(3, 1)), N'110/70', N'Удовлетворительное')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (11, 5, CAST(N'2024-02-16' AS Date), N'Кеторол, Гипсовая повязка', CAST(37.0 AS Decimal(3, 1)), N'115/75', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (12, 5, CAST(N'2024-02-17' AS Date), N'Кеторол', CAST(36.8 AS Decimal(3, 1)), N'115/75', N'Удовлетворительное')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (13, 6, CAST(N'2024-03-02' AS Date), N'Но-шпа, Урсофальк', CAST(37.8 AS Decimal(3, 1)), N'125/85', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (14, 7, CAST(N'2024-03-06' AS Date), N'Амброксол, Аскорил', CAST(38.0 AS Decimal(3, 1)), N'120/80', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (15, 8, CAST(N'2024-03-11' AS Date), N'Эналаприл', CAST(36.6 AS Decimal(3, 1)), N'145/95', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (16, 9, CAST(N'2024-03-13' AS Date), N'Диклофенак, Мидокалм', CAST(36.8 AS Decimal(3, 1)), N'130/85', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (17, 10, CAST(N'2024-03-16' AS Date), N'Троксевазин, Кеторол', CAST(36.5 AS Decimal(3, 1)), N'115/70', N'Удовлетворительное')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (18, 11, CAST(N'2024-04-02' AS Date), N'Ибупрофен', CAST(37.2 AS Decimal(3, 1)), N'120/80', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (19, 12, CAST(N'2024-04-04' AS Date), N'Арбидол', CAST(37.5 AS Decimal(3, 1)), N'118/78', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (20, 13, CAST(N'2024-04-06' AS Date), N'Нитроглицерин', CAST(36.6 AS Decimal(3, 1)), N'150/95', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (21, 14, CAST(N'2024-04-09' AS Date), N'Нейромультивит', CAST(36.6 AS Decimal(3, 1)), N'125/80', N'Удовлетворительное')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (22, 15, CAST(N'2024-04-11' AS Date), N'Кеторол, Гипс', CAST(37.5 AS Decimal(3, 1)), N'120/80', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (23, 16, CAST(N'2024-04-13' AS Date), N'Но-шпа, Урсофальк', CAST(38.0 AS Decimal(3, 1)), N'130/85', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (24, 17, CAST(N'2024-04-16' AS Date), N'Амоксициллин, АЦЦ', CAST(38.5 AS Decimal(3, 1)), N'125/85', N'Тяжелое')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (25, 18, CAST(N'2024-04-19' AS Date), N'Кордарон', CAST(36.6 AS Decimal(3, 1)), N'135/90', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (26, 19, CAST(N'2024-04-21' AS Date), N'Диклофенак', CAST(36.6 AS Decimal(3, 1)), N'115/75', N'Удовлетворительное')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (27, 20, CAST(N'2024-04-23' AS Date), N'Кеторол, Фиксация', CAST(37.0 AS Decimal(3, 1)), N'120/80', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (28, 21, CAST(N'2024-05-02' AS Date), N'Креон, Но-шпа', CAST(37.5 AS Decimal(3, 1)), N'125/85', N'Среднее')
INSERT [dbo].[TreatmentSheets] ([Id_записи], [Id_истории], [Дата_лечения], [Лекарства], [Температура], [Давление], [Состояние]) VALUES (29, 21, CAST(N'2024-05-03' AS Date), N'Креон', CAST(36.8 AS Decimal(3, 1)), N'120/80', N'Удовлетворительное')
SET IDENTITY_INSERT [dbo].[TreatmentSheets] OFF
GO
/****** Объект:  Index [UQ_Departments_Head]    Дата создания скрипта: 13.10.2026 18:05:50 ******/
ALTER TABLE [dbo].[Departments] ADD  CONSTRAINT [UQ_Departments_Head] UNIQUE NONCLUSTERED
(
	[Id_заведующего] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Doctors] ADD  CONSTRAINT [DF_Doctors_Address]  DEFAULT (N'Не указан') FOR [Адрес]
GO
ALTER TABLE [dbo].[Patients] ADD  CONSTRAINT [DF_Patients_Address]  DEFAULT (N'Не указан') FOR [Адрес]
GO
ALTER TABLE [dbo].[Patients] ADD  CONSTRAINT [DF_Patients_City]  DEFAULT (N'Уфа') FOR [Город]
GO
ALTER TABLE [dbo].[Departments]  WITH CHECK ADD  CONSTRAINT [FK_Departments_Doctors_Head] FOREIGN KEY([Id_заведующего])
REFERENCES [dbo].[Doctors] ([Id_врача])
GO
ALTER TABLE [dbo].[Departments] CHECK CONSTRAINT [FK_Departments_Doctors_Head]
GO
ALTER TABLE [dbo].[Doctors]  WITH CHECK ADD  CONSTRAINT [FK_Doctors_Departments] FOREIGN KEY([Id_отделения])
REFERENCES [dbo].[Departments] ([Id_отделения])
GO
ALTER TABLE [dbo].[Doctors] CHECK CONSTRAINT [FK_Doctors_Departments]
GO
ALTER TABLE [dbo].[MedicalHistories]  WITH CHECK ADD  CONSTRAINT [FK_MedicalHistories_Doctors] FOREIGN KEY([Id_врача])
REFERENCES [dbo].[Doctors] ([Id_врача])
GO
ALTER TABLE [dbo].[MedicalHistories] CHECK CONSTRAINT [FK_MedicalHistories_Doctors]
GO
ALTER TABLE [dbo].[MedicalHistories]  WITH NOCHECK ADD  CONSTRAINT [FK_MedicalHistories_Patients] FOREIGN KEY([Id_пациента])
REFERENCES [dbo].[Patients] ([Id_пациента])
GO
ALTER TABLE [dbo].[MedicalHistories] NOCHECK CONSTRAINT [FK_MedicalHistories_Patients]
GO
ALTER TABLE [dbo].[TreatmentSheets]  WITH CHECK ADD  CONSTRAINT [FK_TreatmentSheets_MedicalHistories] FOREIGN KEY([Id_истории])
REFERENCES [dbo].[MedicalHistories] ([Id_истории])
GO
ALTER TABLE [dbo].[TreatmentSheets] CHECK CONSTRAINT [FK_TreatmentSheets_MedicalHistories]
GO
ALTER TABLE [dbo].[Doctors]  WITH CHECK ADD  CONSTRAINT [CHK_Doctors_Position] CHECK  (([Должность]=N'Врач-травматолог' OR [Должность]=N'Врач-невролог' OR [Должность]=N'Врач-кардиолог' OR [Должность]=N'Врач-терапевт' OR [Должность]=N'Врач-хирург' OR [Должность]=N'Заведующий отделением'))
GO
ALTER TABLE [dbo].[Doctors] CHECK CONSTRAINT [CHK_Doctors_Position]
GO
ALTER TABLE [dbo].[MedicalHistories]  WITH CHECK ADD  CONSTRAINT [CHK_MedicalHistories_Dates] CHECK  (([Дата_вылечивания] IS NULL OR [Дата_вылечивания]>=[Дата_заболевания]))
GO
ALTER TABLE [dbo].[MedicalHistories] CHECK CONSTRAINT [CHK_MedicalHistories_Dates]
GO
ALTER TABLE [dbo].[MedicalHistories]  WITH CHECK ADD  CONSTRAINT [CHK_MedicalHistories_StartDate] CHECK  (([Дата_заболевания]<=getdate()))
GO
ALTER TABLE [dbo].[MedicalHistories] CHECK CONSTRAINT [CHK_MedicalHistories_StartDate]
GO
ALTER TABLE [dbo].[MedicalHistories]  WITH CHECK ADD  CONSTRAINT [CHK_MedicalHistories_Treatment] CHECK  (([Вид_лечения]=N'Стационарно' OR [Вид_лечения]=N'Амбулаторно'))
GO
ALTER TABLE [dbo].[MedicalHistories] CHECK CONSTRAINT [CHK_MedicalHistories_Treatment]
GO
ALTER TABLE [dbo].[Patients]  WITH CHECK ADD  CONSTRAINT [CHK_Patients_BirthDate] CHECK  (([Дата_рождения]<=getdate()))
GO
ALTER TABLE [dbo].[Patients] CHECK CONSTRAINT [CHK_Patients_BirthDate]
GO
ALTER TABLE [dbo].[Patients]  WITH CHECK ADD  CONSTRAINT [CHK_Patients_Gender] CHECK  (([Пол]='Ж' OR [Пол]='М'))
GO
ALTER TABLE [dbo].[Patients] CHECK CONSTRAINT [CHK_Patients_Gender]
GO
ALTER TABLE [dbo].[TreatmentSheets]  WITH CHECK ADD  CONSTRAINT [CHK_TreatmentSheets_Temperature] CHECK  (([Температура]>=(34.0) AND [Температура]<=(42.0)))
GO
ALTER TABLE [dbo].[TreatmentSheets] CHECK CONSTRAINT [CHK_TreatmentSheets_Temperature]
GO
USE [master]
GO
ALTER DATABASE [HospitalBD] SET  READ_WRITE
GO
