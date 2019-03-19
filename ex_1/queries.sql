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
