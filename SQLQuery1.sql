--1. Lentel?je Abonentas prid?kite papildom? atribut? "nuolaida" Decimal(3,2) tipo NOT NULL Default 0,00 reikšm?.
ALTER TABLE RRT.dbo.Abonentas ADD Nuolaida DECIMAL(3,2) not null DEFAULT 0.00

--2. Lentel?je Asmuo prid?kite atribut? "elPastas" varchar(50) tipo NULL reikšm?.
ALTER TABLE RRT.dbo.Asmuo ADD elPastas VARCHAR(50)

--3. Sukurkite lentel? Domenas su atributais "domenoID" int tipo, "pavadinimas" varchar(15) tipo. Atributas "domenoID" turi tur?ti IDENTITY parametr?. 
CREATE TABLE Domenas(
domenoID INT not null IDENTITY(1,1)
	CONSTRAINT PK_Domenas PRIMARY KEY,
pavadinimas VARCHAR(15) not null
)

--4.? lentel? Domenas ?veskite ?rašus: "gmail.com", "yahoo.com", "hotmail.com", "viko.lt".
INSERT INTO Domenas(pavadinimas)
VALUES
	('gmail.com'),
	('yahoo.com'),	
	('hotmail.com'),
	('viko.lt')

--5. Atnaujinkite lentel?s Asmuo ?rašus ?vedant el pašto adres?. Kiekvienam asmeniui el. pašto adresas formuojamas taip: vardas.pavarde@domenas. domenas atsitiktinai parenkamas iš lentel?s Domenas. 

UPDATE rrt.dbo.Domenas
SET RRT.dbo.Asmuo.elPastas = Asmuo.vardas+'.'+Asmuo.pavarde+'@'+randomPov FROM Asmuo, ( 
SELECT TOP 1 RRT.dbo.Domenas.pavadinimas as randomPov FROM dbo.Domenas
ORDER BY newID() 
) as randomPov



--6. Sukurkite lentel? Mob_telefonas su atributais "mobTelID" int tipo, "gamintojas" varchar(15) tipo, "modelis" varchar(25) tipo, "kaina" float tipo, "kaina/men" float tipo. 
CREATE TABLE Mob_telefonas(
	mobTelID INT NOT NULL IDENTITY(1,1)
		CONSTRAINT PK_Mob_telefonas PRIMARY KEY,
	gamintojas VARCHAR(15) NOT NULL,
	modelis VARCHAR(25) NOT NULL,
	kaina FLOAT NOT NULL,
	kainaMenesiui FLOAT NOT NULL
)

--7. Lentel?je Abonentas prid?kite papildom? atribut? "mobTelID" int tipo. Atminkite, jog ne visi abonentai kartu su planu ?sigyja mobil?j? telefon?. 
ALTER TABLE RRT.dbo.Abonentas ADD mobTelID INT

--8. Sukurkite išorinio rakto s?ryš? tarp lentel?s Abonento atributo "mobTelID" ir lentel?s Mob_Telefonas atributo "mobTelID". 
ALTER TABLE RRT.dbo.Abonentas
		ADD CONSTRAINT FK_Abonentas_Mob_telefonas FOREIGN KEY(mobTelID) REFERENCES Mob_telefonas (mobTelID)

--9. Lentel? Mob_telefonas užpildykite duomenimis iš .txt failo. Failas yra ?ia. Naudokite BULK INSERT komand?.
BULK INSERT RRT.dbo.Mob_telefonas FROM 'C:\Users\vaini\OneDrive\Desktop\5 Semestras\DB valdym? sistemos\Mobilieji telefonai.txt'
WITH
(
FIRSTROW = 2,
DATAFILETYPE = 'char',
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)

TRUNCATE TABLE RRT.dbo.Mob_telefeonas

--10. Atnaujinkite lenteles Abonentas irašus ivedant atributo "mobTelID" reikšmes. Mobiluji telefona pasirinko tie abonentai, kuriu sutarties pabaigos data yra neapibrežta.
--Kiekvienam abonentui parenkamas atsitiktinis mobilusis telefonas. 

UPDATE rrt.dbo.Abonentas
SET Abonentas.mobTelID = mobileData.ranndomPhoneID
FROM
(
SELECT RRT.dbo.Abonentas.abonentoID as abonentasid ,ABS(CHECKSUM(NEWID())%randomPov.counte) +31 as ranndomPhoneID FROM RRT.dbo.Abonentas, (
SELECT count(RRT.dbo.Mob_telefonas.modelis) as counte FROM rrt.dbo.Mob_telefonas
) AS randomPov
WHERE rrt.dbo.Abonentas.sutartiesPabaiga is null
) as mobileData
WHERE Abonentas.abonentoID = mobileData.abonentasid