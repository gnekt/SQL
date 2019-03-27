--Select name,surname and number of tracks of an artist with idartista=230

select a.nome,a.cognome,count(b.idbrano) as "Tracks Number"
from composizione as c, brano as b, artista as a
where c.idbrano=b.idbrano and c.idartista=230 and c.idartista=a.idartista
group by(a.idartista)

--Select disc's date and number of disk 

select annodisco,count(iddisco) as "Numero Dischi"
from disco
where annodisco is not NULL
group by(annodisco)
order by annodisco ASC
---------------------------------------------
select  d.iddisco
from disco as d
where d.annodisco < any ( select r.annoregistrazione 
						  from contiene as c inner join registrazione as r
						   on c.idbrano=r.idbrano and c.idartista = r.idartista 
						   where d.iddisco = c.iddisco);
						   
----------------------------------------------               
Select Distinct D.*
From DISCO D,
CONTIENE C,
REGISTRAZIONE R
Where D.IDDISCO = C.IDDISCO
and C.IDBRANO = R.IDBRANO
and C.IDARTISTA = R.IDARTISTA
and R.AnnoRegistrazione > D.AnnoDisco
order by d.iddisco
-------------------------------------------------

--I codici ed i titoli dei dischi che
--contengono brani di cui non si conosce
--lanno di registrazione
select d.*,c.*,r.*
from contiene as c 
                  inner join disco as d on c.iddisco = d.iddisco
				  inner join registrazione as r on c.idartista = r.idartista and c.idbrano = r.idbrano
				  where r.annoregistrazione = 1980
