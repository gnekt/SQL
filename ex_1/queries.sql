--Select name,surname and number of tracks of an artist with idartista=230

select a.nome,a.cognome,count(b.idbrano) as "Tracks Number"
from composizione as c, brano as b, artista as a
where c.idbrano=b.idbrano and c.idartista=1 and c.idartista=a.idartista
group by(a.idartista)
