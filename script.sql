/*
	*******
			PARTI I :
            Structure de la base de donnée
	*******
*/

USE biblio;

-- les tuples dans la base de donné
select count(*) from adherents; -- 30 tuples
select count(*) from emprunter; --  33 tuples
select count(*) from livres; -- 32 tuples
select count(*) from oeuvres; -- 18 tuples
select count(*) from person; -- 6 tuples

-- le nombre d'attribu

select count(*) from information_schema.columns where table_schema= 'biblio' and table_name= 'adherents'; -- 5 attributs
select count(*) from information_schema.columns where table_schema= 'biblio' and table_name= 'emprunter'; -- 5 attributs
select count(*) from information_schema.columns where table_schema= 'biblio' and table_name= 'livres'; -- 3 attributs
select count(*) from information_schema.columns where table_schema= 'biblio' and table_name= 'oeuvres'; -- 5 attributs
select count(*) from information_schema.columns where table_schema= 'biblio' and table_name= 'person'; -- 4 attributs

-- les clés primaires de la base de donnée 'biblio'
select table_name,  column_name
from information_schema.key_column_usage -- adherents: NA; emprunter:NL; emprunter:dateEmp; livres: NL; oeuvres: NO;
where constraint_schema = 'biblio' and constraint_name = 'PRIMARY';

/* 
	********** 
				PARTIE II:
				INTERACTION AVEC LA BASE DE DONNEE
    **********
*/
-- 9.les livres actuellement emprunté : DateRet is null
select titre from livres
join emprunter
on livres.NL = emprunter.NL 
join oeuvres
on livres.NO = oeuvres.NO
where dateRet is null;

-- 10.les livres empruntés par Jeannette Lecoeur
select nom,prenom,titre,auteur,dateEmp from livres
join emprunter
on livres.NL = emprunter.NL 
join oeuvres
on livres.NO = oeuvres.NO
join adherents
on adherents.NA = emprunter.NA
where prenom= 'Jeanette' and nom= 'Lecoeur';

-- 11. les livres empruntés en septembre 2009 (dateEmp)
select titre from livres
join emprunter
on livres.NL = emprunter.NL 
join oeuvres
on livres.NO = oeuvres.NO
where  DATE_FORMAT(dateEmp, "%m-%y") = DATE_FORMAT(09-09, "%d-%m");

-- 12.Tous les adhérents qui ont emprunté un livre de Fedor Dostoievski.
select nom,prenom,titre,auteur,dateEmp from livres
join emprunter
on livres.NL = emprunter.NL 
join oeuvres
on livres.NO = oeuvres.NO
join adherents
on adherents.NA = emprunter.NA
where auteur = 'Fedor DOSTOIEVSKI'; -- Yvan Dupont

-- 13.Un nouvel adhérent vient de s’inscrire : Olivier DUPOND, 76, quai de la Loire, 75019 Paris, téléphone : 0102030405
Insert into adherents (nom, prenom, adr, tel)
values ('DUPOND', 'Olivie', '76, quai de la Loire, 75019 Paris','0102030405')

-- 14.Martine CROZIER vient d’emprunter « Au coeur des ténèbres » que vous venez d’ajouter et « Le rouge et le noir » chez Hachette, livre n°23. Faire les mises à jour de la BD.
