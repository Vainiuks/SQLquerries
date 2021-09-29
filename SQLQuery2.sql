--1. Parašykite užklaus?, kuri išveda lentel?je "Miestas" esan?i? ?raš? kiek?.
SELECT count(miestoID) as 'Viso irasu' 
FROM Miestas

--2. Parašykite užklaus?, kuri išveda planus (pavadinimas, kaina) iš lentel?s "Planas" ? kuri? komplektacij? ?trauktas tam tikras interneto planas. 
--Išvedam? lauk? aib? papildyti informacija apie interneto planus (pavadinimas, suteikt? MB kiekis ir kaina) iš lentel?s "InternetoPlanas" bei atitinkamu operatoriaus pavadinimu iš lentel?s "Operatorius".
SELECT dbo.Planas.planoPavadinimas, dbo.Planas.kaina,
dbo.InternetoPlanas.intPlanoPavadinimas, dbo.InternetoPlanas.kiekisMB, dbo.InternetoPlanas.kaina,
dbo.Operatorius.operatoriausPavadinimas
FROM dbo.Planas, dbo.InternetoPlanas, dbo.Operatorius
WHERE dbo.Planas.internetoPlanoID = dbo.InternetoPlanas.internetoPlanoID
AND dbo.Planas.operatoriausID = dbo.Operatorius.operatoriausID
AND dbo.InternetoPlanas.operatoriausID = dbo.Operatorius.operatoriausID

--3. Parašykite užklaus?, kuri išveda visus operatorius (pavadinimas) bei j? si?lomus planus (pavadinimas, kaina) iš lentel?s "Planas" ? kuri? komplektacij? ?traukta 100 ar daugiau nemokam? minu?i? pokalbiams Lietuvos tinkle.
SELECT dbo.Operatorius.operatoriausPavadinimas,
dbo.Planas.planoPavadinimas, dbo.Planas.kaina
FROM dbo.Operatorius, dbo.Planas, dbo.PlanoRinkinys, dbo.Lengvata
WHERE dbo.Operatorius.operatoriausID = dbo.Planas.operatoriausID
AND dbo.Planas.planoID = dbo.PlanoRinkinys.planoID
AND dbo.PlanoRinkinys.rinkinioID = dbo.Lengvata.rinkinioID
AND dbo.Lengvata.kiekis > 100


--4. Parašykite užklaus?, kuri išveda suvestin? apie naudotoj? kiek? kiekviename mieste.
SELECT dbo.Miestas.miestoPavadinimas, COUNT(dbo.asmuo.miestoID) as 'Naudotoj? kiekis mieste'
FROM dbo.Asmuo, dbo.Miestas
WHERE dbo.Miestas.miestoID = dbo.Asmuo.miestoID
GROUP BY dbo.Miestas.miestoPavadinimas
ORDER BY dbo.Miestas.miestoPavadinimas


--5. Parašykite užklaus?, kuri išveda miestus, kuriuose n?ra n? vieno naudotojo.
SELECT dbo.Miestas.miestoPavadinimas, COUNT(dbo.Asmuo.miestoID)
FROM dbo.Asmuo, dbo.Miestas
WHERE dbo.Miestas.miestoID = dbo.Asmuo.miestoID
GROUP BY dbo.Miestas.miestoPavadinimas
HAVING COUNT(dbo.Asmuo.miestoID) = 0
ORDER BY dbo.Miestas.miestoPavadinimas

--6.


--7. neveikia
SELECT dbo.Operatorius.operatoriausPavadinimas, COUNT(dbo.Planas.operatoriausID)
FROM dbo.Operatorius, dbo.Planas
WHERE dbo.Operatorius.operatoriausID = dbo.Planas.operatoriausID
GROUP BY dbo.Operatorius.operatoriausPavadinimas



--8. Parašykite užklaus?, kuri išveda s?raš? asmen?, kurie užsisak? bet kok? plan? laikotarpyje 2013 01 03 - 2013 01 10. Rezultate reikia nurodyti asmens vard?, pavard?, plano pavadinim? ir sutarties pradži?.
SELECT dbo.Asmuo.vardas, dbo.Asmuo.pavarde, dbo.Planas.planoPavadinimas, dbo.Abonentas.sutartiesPradzia
FROM dbo.Asmuo, dbo.Planas, dbo.Abonentas
WHERE dbo.Planas.planoID = dbo.Abonentas.planoID
AND dbo.Abonentas.asmensID = dbo.Asmuo.asmensID
AND dbo.Abonentas.sutartiesPradzia >= '2013-01-03'
AND dbo.Abonentas.sutartiesPradzia <= '2013-01-10'


--9. Parašykite užklaus?, kuri išveda vis? operatori? si?lom? plan? kain? vidurk?. Užklauso turi išvesti operatoriaus pavadinim?, vidutin? kain?. Rezultatus surikiuoti kain? maž?jimo tvarka.
SELECT dbo.Operatorius.operatoriausPavadinimas,
AVG(dbo.Planas.kaina) as 'Vidutin? plan? kainos vidurkis'
FROM dbo.Operatorius, dbo.Planas
WHERE dbo.Operatorius.operatoriausID = dbo.Planas.operatoriausID
GROUP BY dbo.Operatorius.operatoriausPavadinimas
ORDER BY 'Vidutin? plan? kainos vidurkis' DESC

--10. Parašykite užklaus?, nustatan?i? kiek papildom? paslaug? teikia kiekvienas operatorius. Užklausa turi išvesti operatoriaus pavadinim? ir paslaug? kiek?.
SELECT dbo.Operatorius.operatoriausPavadinimas, COUNT(dbo.OperatoriausPapildomaPaslauga.operatoriausID) as 'Operatoriaus suteikiamas papildomu paslaugus skaicius' 
FROM dbo.Operatorius, dbo.OperatoriausPapildomaPaslauga
WHERE dbo.OperatoriausPapildomaPaslauga.operatoriausID = dbo.Operatorius.operatoriausID
GROUP BY dbo.Operatorius.operatoriausPavadinimas

