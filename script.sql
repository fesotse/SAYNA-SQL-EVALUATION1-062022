/*
	*******
			PARTI I :
            Structure de la base de donnée
	*******
*/

USE biblio;
ALTER TABLE emprunter ALTER COLUMN dureeMax SET DEFAULT 14;
-- les tuples dans la base de donné
select count(*) from adherents; -- 30 tuples
select count(*) from emprunter; --  33 tuples
select count(*) from livres; -- 32 tuples
select count(*) from oeuvres; -- 18 tuples

-- le nombre d'attribu

select count(*) from information_schema.columns where table_schema= 'biblio' and table_name= 'adherents'; -- 5 attributs
select count(*) from information_schema.columns where table_schema= 'biblio' and table_name= 'emprunter'; -- 5 attributs
select count(*) from information_schema.columns where table_schema= 'biblio' and table_name= 'livres'; -- 3 attributs
select count(*) from information_schema.columns where table_schema= 'biblio' and table_name= 'oeuvres'; -- 5 attributs

-- les clés primaires de la base de donnée 'biblio'
select table_name,  column_name
from information_schema.key_column_usage 
where constraint_schema = 'biblio' and constraint_name = 'PRIMARY'; -- adherents: NA; emprunter:NL; emprunter:dateEmp; livres: NL; oeuvres: NO;

/* 
	********** 
				PARTIE II:
				INTERACTION AVEC LA BASE DE DONNEE
    **********
*/
-- 6.les livres actuellement emprunté : DateRet is null
select titre from livres
join emprunter
on livres.NL = emprunter.NL 
join oeuvres
on livres.NO = oeuvres.NO
where dateRet is null;

-- 7.les livres empruntés par Jeannette Lecoeur
select nom,prenom,titre,auteur,dateEmp from livres
join emprunter
on livres.NL = emprunter.NL 
join oeuvres
on livres.NO = oeuvres.NO
join adherents
on adherents.NA = emprunter.NA
where prenom= 'Jeanette' and nom= 'Lecoeur'; -- le livre Narcisse et Goldmun a été emprunté 2 fois mais avec des dates différentes 2021-08-22 et 2022-06-01

-- 8. les livres empruntés en septembre 2009 (dateEmp)
select titre from livres
join emprunter
on livres.NL = emprunter.NL 
join oeuvres
on livres.NO = oeuvres.NO
where  month(emprunter.dateEmp)='9' and year(emprunter.dateEmp)='2009';
/* le resultat est null car aucun livre n'est emprunté en 2009*/

-- 9.Tous les adhérents qui ont emprunté un livre de Fedor Dostoievski.
select nom,prenom,titre,auteur,dateEmp from livres
join emprunter
on livres.NL = emprunter.NL 
join oeuvres
on livres.NO = oeuvres.NO
join adherents
on adherents.NA = emprunter.NA
where auteur = 'Fedor DOSTOIEVSKI'; -- Yvan Dupont

-- 10.Un nouvel adhérent vient de s’inscrire : Olivier DUPOND, 76, quai de la Loire, 75019 Paris, téléphone : 0102030405
Insert into adherents (nom, prenom, adr, tel)
values ('DUPOND', 'Olivier', '76, quai de la Loire, 75019 Paris','0102030405');

-- 11.Martine CROZIER vient d’emprunter « Au coeur des ténèbres » que vous venez d’ajouter et « Le rouge et le noir » chez Hachette, livre n°23. Faire les mises à jour de la BD. NA=7
Insert into oeuvres (titre, auteur,annee, genre)
Values ("Au coeur des ténébres","Folio", 2012, "théatre");
Insert into livres(editeur,NO)
values ('Hachette', 19);
insert into emprunter (NL,DateEmp,NA)
values (33,curdate(),7), (23, curdate(),7);

-- 12.M. Cyril FREDERIC ramène les livres qu’il a empruntés.
-- les livres qu'il a emprunté:
select * from adherents
left join emprunter
on adherents.NA = emprunter.NA
where adherents.nom = "FREDERIC"; -- Ainsi NA= 28 et deux livres sont empruntés
-- mise à jour des livres rendus
UPDATE emprunter set dateRet= curdate() where NA=28 and dateRet is null;

-- 13.M. Cyril FREDERIC essaye d’emprunter le livre n°23. Ecrire la requête. 
select * from adherents where nom = 'FREDERIC'; -- NA:28
Insert into emprunter (NL, dateEmp,NA)
values(23, curdate(),28);
/* Un erreur se produit car il y a un duplicata du champ '23-2022-06-29' pour la clef 'PRIMARY'
select * from emprunter where NL=23;
Le livre est encore emprunté par l'utilisateur NA:7
*/

-- 14.M. Cyril FREDERIC essaye d’emprunter le livre n°29. Écrire la requête. 
select * from adherents where nom = 'FREDERIC'; -- NA:28
Insert into emprunter (NL, dateEmp,NA)
values(29, curdate(),28);
/* Tout se passe bien, l'insertion est un succés*/

-- 15.Quels sont le ou les auteurs du titre « Voyage au bout de la nuit »
select auteur from oeuvres
left join livres
on oeuvres.NO = livres.NO
where titre = 'Voyage au bout de la nuit'; -- Louis-Ferdinand CELINE

-- 16.Quels sont les ou les éditeurs du titre « Narcisse et Goldmund »
select distinct editeur from oeuvres 
left join livres
on oeuvres.NO = livres.NO
where titre = 'Narcisse et Goldmund'; -- GF


-- 17.Quels sont les adhérents actuellement en retard ?
select distinct nom,prenom from emprunter 
left join adherents
on emprunter.NA = adherents.NA
where datediff(`emprunter`.`dateRet`, `emprunter`.`dateEmp`)>dureeMax;
/* Albert DURANT, Martine CROZIER, Jacques DUFOUR, Jeanette LECOEUR*/


-- 18.Quels sont les livres actuellement en retard ?


select titre from emprunter 
left join livres
on emprunter.NL = livres.NL
left join oeuvres
on livres.NO= oeuvres.NO
where datediff(curdate(), `emprunter`.`dateEmp`)>dureeMax and `emprunter`.`dateRet` is null;
/*Lettres de Gourgounel, Narcisse et Goldmund*/


-- 19.Quels sont les adhérents en retard, avec le nombre de livres en retard et la moyenne du nombre de jours de retard.

select nom, prenom,avg(datediff(curdate(), `emprunter`.`dateEmp`)-`emprunter`.`dureeMax`) from emprunter 
left join livres
on emprunter.NL = livres.NL
left join oeuvres
on livres.NO= oeuvres.NO 
left join adherents
on emprunter.NA = adherents.NA 
where datediff(curdate(), `emprunter`.`dateEmp`)>dureeMax and `emprunter`.`dateRet` is null
group by adherents.NA;
;


-- 20.Nombre de livres empruntés par auteur.

select auteur, count(titre) from emprunter, livres, oeuvres
where oeuvres.NO = livres.NO and livres.NL= emprunter.NL
group by oeuvres.auteur;


-- 21.Nombre de livres empruntés par éditeur.

select auteur, count(titre) from emprunter, livres, oeuvres
where oeuvres.NO = livres.NO and livres.NL= emprunter.NL
group by livres.editeur;


-- 22.Durée moyenne des emprunts rendus. On commencera par afficher les durées des emprunts rendus.
select (datediff(`emprunter`.`dateRet`, `emprunter`.`dateEmp`)) from emprunter where `emprunter`.`dateRet` is not null;
select avg(datediff(`emprunter`.`dateRet`, `emprunter`.`dateEmp`)) from emprunter where `emprunter`.`dateRet` is not null;


-- 23.Durée moyenne des retards pour l’ensemble des emprunts. rendu ou non rendu
SELECT
    prenom,nom,(DATEDIFF(IFNULL(`emprunter`.`dateRet`, CURDATE()),
            `emprunter`.`dateEmp`)) as `moyenne des retards (en jour)`
FROM
    emprunter, adherents
WHERE
    DATEDIFF(IFNULL(`emprunter`.`dateRet`, CURDATE()),
            `emprunter`.`dateEmp`) > dureeMax and emprunter.NA=adherents.NA;


-- 24.Durée moyenne des retards parmi les seuls retardataires.
SELECT
    avg(DATEDIFF( CURDATE(),
            `emprunter`.`dateEmp`)) as `moyenne des retards (en jour)`
FROM
    emprunter
WHERE
    DATEDIFF(CURDATE(),
            `emprunter`.`dateEmp`) > dureeMax 
            and `emprunter`.`dateRet` is null;