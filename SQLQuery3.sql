--1.Parašykite užklaus?, nustatan?i? kokias papildomas paslaugas teikia mobiliojo ryšio operatorius TELE2.
--Užklausa turi išvesti paslaugos pavadinim? ir kain?.
SELECT  PapildomaPaslauga.papildomosPaslaugosPavadinimas ,OperatoriausPapildomaPaslauga.kaina
FROM OperatoriausPapildomaPaslauga, PapildomaPaslauga, Operatorius
WHERE Operatorius.operatoriausPavadinimas = 'Tele2'
AND PapildomaPaslauga.papildomosPaslaugosID = OperatoriausPapildomaPaslauga.papildomosPaslaugosID
AND Operatorius.operatoriausID = OperatoriausPapildomaPaslauga.operatoriausID

--2.Parašykite užklaus?, išvedan?i? papildomas paslaugas, kurias si?lo visi mobiliojo ryšio operatoriai.
--Užklausa turi išvesti operatoriaus pavadinim?, papildomos paslaugos pavadinim? bei kain?.
SELECT Operatorius.operatoriausPavadinimas, OperatoriausPapildomaPaslauga.kaina, PapildomaPaslauga.papildomosPaslaugosPavadinimas
FROM Operatorius, OperatoriausPapildomaPaslauga, PapildomaPaslauga
WHERE Operatorius.operatoriausID = OperatoriausPapildomaPaslauga.operatoriausID
AND OperatoriausPapildomaPaslauga.papildomosPaslaugosID = PapildomaPaslauga.papildomosPaslaugosID


--3.Parašykite užklaus?, išvedan?i? kiekvienai zonai priklausan?i? valstybi? skai?i?
SELECT Zona.zonosPavadinimas, COUNT(dbo.Salis.zonosID) as 'Zonoje esanciu valstybiu skaicius'
FROM Zona, dbo.Salis
WHERE Zona.zonosID = Salis.zonosID
GROUP BY Zona.zonosPavadinimas

--4.Parašykite užklaus?, kuri išveda operatoriaus pavadinim?, si?lan?io brangiausius skambu?ius ? Meksik?.
SELECT TOP 1 Operatorius.operatoriausPavadinimas, MAX(PaslaugosKainaZonoje.kaina) as 'Skambucio kaina i Meksika'
FROM Operatorius, PaslaugosKainaZonoje, Zona, Salis
WHERE Operatorius.operatoriausID = PaslaugosKainaZonoje.operatoriausID
AND PaslaugosKainaZonoje.zonosID = 3
AND PaslaugosKainaZonoje.zonosID = Zona.zonosID
AND Zona.zonosID = 3
AND Salis.saliesPavadinimas = 'Meksika'
GROUP BY Operatorius.operatoriausPavadinimas
ORDER BY 'Skambucio kaina i Meksika' DESC


--5.Parašykite užklausą, kuri nustato interneto planą, neįtrauktą į mokėjimo planą, pagal kurį 1MB kaina yra mažiausia. 
--Užklausa turi išvesti operatoriaus pavadinimą, interneto plano pavadinimą ir 1MB kaina.
SELECT TOP 1 RRT.dbo.Operatorius.operatoriausPavadinimas, RRT.dbo.InternetoPlanas.intPlanoPavadinimas,RRT.dbo.InternetoPlanas.kaina / RRT.dbo.InternetoPlanas.kiekisMB AS Kaina_1MB FROM RRT.dbo.Operatorius, RRT.dbo.InternetoPlanas,
(
SELECT A.internetoPlanoID
FROM RRT.dbo.InternetoPlanas as A
LEFT JOIN RRT.dbo.Planas as B ON a.internetoPlanoID = b.internetoPlanoID
WHERE B.internetoPlanoID IS NULL
) as InternetoPlanoID
WHERE Operatorius.operatoriausID = InternetoPlanas.operatoriausID
AND InternetoPlanoID.internetoPlanoID = InternetoPlanas.internetoPlanoID
AND RRT.dbo.InternetoPlanas.kaina / RRT.dbo.InternetoPlanas.kiekisMB > 0
GROUP BY RRT.dbo.Operatorius.operatoriausPavadinimas, RRT.dbo.InternetoPlanas.intPlanoPavadinimas,RRT.dbo.InternetoPlanas.kaina, RRT.dbo.InternetoPlanas.kiekisMB
ORDER BY Kaina_1MB asc


--6.Išveskite procentine išraiška abonent? pasiskirstym? tarp operatori?.
DECLARE @VisoAbonentu as INT = (SELECT MAX(Abonentas.abonentoID) FROM dbo.Abonentas)
SELECT Operatorius.operatoriausPavadinimas, ((COUNT(dbo.Abonentas.planoID) * 100.0 / @VisoAbonentu)) as 'Operatoriams priklausanciu abonentu kiekis'
FROM Operatorius, Abonentas, Planas
WHERE Operatorius.operatoriausID = Planas.operatoriausID
AND Abonentas.planoID = Planas.planoID
GROUP BY Operatorius.operatoriausPavadinimas


--7.Išveskite 3 populiariausius tarp abonentų mobiliojo ryšio planus. Jei yra daugiau nei 2 planai turintys tą patį kiekį abonentų, išvesti visus tokius planus. 
--Užklausa turi išestiv plano pavadinimą ir abonentų kiekį.

SELECT RRT.DBO.Planas.planoPavadinimas, AbonentuKiekis.AbonentuKiekiss FROM RRT.dbo.Planas, RRT.dbo.Abonentas,
(
SELECT DISTINCT TOP 3 COUNT(dbo.Abonentas.planoID) as AbonentuKiekiss
FROM dbo.Planas, dbo.Abonentas
WHERE dbo.Planas.planoID = dbo.Abonentas.planoID
GROUP BY dbo.Planas.planoPavadinimas
ORDER BY AbonentuKiekiss DESC
) as AbonentuKiekis
WHERE dbo.Planas.planoID = dbo.Abonentas.planoID
GROUP BY RRT.DBO.Planas.planoPavadinimas, AbonentuKiekis.AbonentuKiekiss
HAVING COUNT(dbo.Abonentas.planoID)= AbonentuKiekis.AbonentuKiekiss



--8.Išvesti dešimties atsitiktini? abonent? informacij?: pilnas vardas, miestas, numeris, sutarties pradžia, sutarties pabaiga, operatoriaus pavadinimas, plano pavadinimas,
--požymis nusakantis ar užsakytas papildomai interneto planas, požymis nusakantis ar užsisakyta papildom? paslaug?.
SELECT TOP 10 RRT.dbo.Asmuo.vardas, RRT.dbo.Asmuo.pavarde AS Vardas, RRT.dbo.Miestas.miestoPavadinimas, RRT.dbo.Abonentas.numeris, RRT.dbo.Abonentas.sutartiesPradzia, RRT.dbo.Abonentas.sutartiesPabaiga,
RRT.dbo.Operatorius.operatoriausPavadinimas, RRT.dbo.Planas.planoPavadinimas, 
RRT.dbo.InternetoPlanas.internetoPlanoID, RRT.dbo.OperatoriausPapildomaPaslauga.operatoriausID,
CASE
WHEN rrt.dbo.UzsakytasInternetoPlanas.atsisakymoData IS NOT NULL THEN 'Turi'
ELSE 'Neturi' 
END AS InternetoPlanoPozymis,
CASE
WHEN rrt.dbo.Abonentas.abonentoID = rrt.dbo.UzsakytaPapildomaPaslauga.abonentoID THEN 'Turi'
ELSE 'Neturi'
END AS PapildomoOperatoriausPozymis
FROM RRT.dbo.Abonentas, RRT.dbo.Asmuo, RRT.dbo.Miestas, RRT.dbo.Operatorius, RRT.dbo.Planas, RRT.dbo.InternetoPlanas, RRT.dbo.OperatoriausPapildomaPaslauga, rrt.dbo.UzsakytasInternetoPlanas, rrt.dbo.UzsakytaPapildomaPaslauga
WHERE Asmuo.miestoID = Miestas.miestoID
AND Asmuo.asmensID = Abonentas.asmensID
AND Abonentas.planoID = Planas.planoID 
AND Planas.operatoriausID = Operatorius.operatoriausID
AND Planas.internetoPlanoID = InternetoPlanas.internetoPlanoID
AND Operatorius.operatoriausID = OperatoriausPapildomaPaslauga.operatoriausID
ORDER BY NEWID()

SELECT TOP 10 RRT.dbo.Asmuo.vardas, RRT.dbo.Asmuo.pavarde, RRT.dbo.Miestas.miestoPavadinimas, RRT.dbo.Abonentas.numeris, RRT.dbo.Abonentas.sutartiesPradzia, 
RRT.dbo.Abonentas.sutartiesPabaiga,
RRT.dbo.Operatorius.operatoriausPavadinimas, RRT.dbo.Planas.planoPavadinimas, 
RRT.dbo.InternetoPlanas.internetoPlanoID, RRT.dbo.OperatoriausPapildomaPaslauga.operatoriausID,
CASE
WHEN rrt.dbo.UzsakytasInternetoPlanas.atsisakymoData IS NOT NULL THEN 'Turi'
ELSE 'Neturi' 
END AS InternetoPlanoPozymis,
CASE
WHEN rrt.dbo.Abonentas.abonentoID = rrt.dbo.UzsakytaPapildomaPaslauga.abonentoID
AND rrt.dbo.UzsakytaPapildomaPaslauga.oprPapildomosPslgsID = rrt.dbo.OperatoriausPapildomaPaslauga.oprPapildomosPslgsID THEN 'Turi'
ELSE 'Neturi'
END AS PapildomoOperatoriausPozymis
FROM RRT.dbo.Abonentas, RRT.dbo.Asmuo, RRT.dbo.Miestas, RRT.dbo.Operatorius, RRT.dbo.Planas, RRT.dbo.InternetoPlanas, RRT.dbo.OperatoriausPapildomaPaslauga,rrt.dbo.UzsakytasInternetoPlanas, rrt.dbo.UzsakytaPapildomaPaslauga
WHERE Asmuo.miestoID = Miestas.miestoID
AND Asmuo.asmensID = Abonentas.asmensID
AND Abonentas.planoID = Planas.planoID 
AND Planas.operatoriausID = Operatorius.operatoriausID
AND Planas.internetoPlanoID = InternetoPlanas.internetoPlanoID
AND Operatorius.operatoriausID = OperatoriausPapildomaPaslauga.operatoriausID
ORDER BY NEWID()
--9.Parašykite užklaus? išvedan?i? TOP 5 abonentus pagal skambu?i? Lietuvos teritorijoje kiek? 2013 met? spalio m?nes?.
SELECT TOP 5  rrt.dbo.Abonentas.abonentoID ,COUNT(RysysP2P.adresatoNumeris) as 'Skambu?iu kiekis'
FROM RysysP2P, Paslauga, Abonentas
WHERE Abonentas.abonentoID = RysysP2P.abonentoID
AND RysysP2P.paslaugosID = Paslauga.paslaugosID
AND Paslauga.paslaugosID = 1
AND RysysP2P.rysioPradzia >= '2013-10-01'
AND RysysP2P.rysioPabaiga <= '2013-10-31'
GROUP BY rrt.dbo.Abonentas.abonentoID
ORDER BY 'Skambu?iu kiekis' desc

--10.Parašykite užklaus?, nustatan?i? populiariausi? užsienio šal? pagal skambu?i? kiek? ? j?. Jei yra kelios vienodai populiarios šalys, išvesti jas visas.
SELECT RRT.dbo.Salis.saliesPavadinimas, skambuciuCount.SkambuciuIAdresatoSaliKiekis FROM RRT.dbo.Salis,dbo.RysysP2P,RRT.dbo.Paslauga,
	(
	SELECT TOP 1 Salis.saliesPavadinimas,
	 COUNT(dbo.RysysP2P.adresatoSalis)  as SkambuciuIAdresatoSaliKiekis 
	FROM Salis, RysysP2P, Paslauga
	WHERE Paslauga.paslaugosID = 4
	AND RysysP2P.adresatoSalis = Salis.saliesKodas
	AND Paslauga.paslaugosID = RysysP2P.paslaugosID
	GROUP BY Salis.saliesPavadinimas
	ORDER BY SkambuciuIAdresatoSaliKiekis DESC
	) AS skambuciuCount
WHERE RysysP2P.adresatoSalis = Salis.saliesKodas AND Paslauga.paslaugosID = RysysP2P.paslaugosID
AND Paslauga.paslaugosID=4
GROUP BY RRT.dbo.Salis.saliesPavadinimas,skambuciuCount.SkambuciuIAdresatoSaliKiekis
HAVING COUNT(dbo.RysysP2P.adresatoSalis)=skambuciuCount.SkambuciuIAdresatoSaliKiekis




