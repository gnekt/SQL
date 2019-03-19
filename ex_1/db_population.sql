delete from contiene;
delete from registrazione;
delete from composizione;
delete from brano;
delete from artista;
delete from disco;

select setseed(0.6);

insert into Disco(IDDisco,TitoloDisco, AnnoDisco)
select generate_series(1,500), random_string(5,20), 
cast(1918+100*random() as integer);
			
update Disco
set annodisco=null
where iddisco % 50 = 0;

insert into Brano(IDBrano,TitoloBrano, AnnoComposizione)
select generate_series(1,2000), random_string(5,20), cast(1918+100*random() as integer);

update Brano
set AnnoComposizione=null
where idbrano % 48 = 0;

insert into artista(idartista, cognome, nome)
select generate_series(1,500), random_surname() , random_name();

update Artista
set nome=null
where idartista % 88 = 0;

insert into Composizione(IDBrano,IDArtista)
select IDBrano, IDArtista 
from Brano, Artista 
order by random() 
limit 4000;

insert into Registrazione(IDBrano,IDArtista,AnnoRegistrazione)
select IDBrano, IDArtista, cast(1918+100*random() as integer)
from Brano, Artista 
order by random() 
limit 6000;

update Registrazione 
set AnnoRegistrazione = cast(1918+100*random() as integer);

insert into Contiene(IDDisco,IDBrano,IDArtista)
select IDDisco, IDBrano, IDArtista
from Disco, Registrazione 
order by random() 
limit 3000;		

						 
						 
-- insert into Disco(IDDisco,TitoloDisco, AnnoDisco)
-- values (501, 'Titolo 1', 2000);

-- insert into Disco(IDDisco,TitoloDisco, AnnoDisco)
-- values (502, 'Titolo 2', 2000);

-- insert into Disco(IDDisco,TitoloDisco, AnnoDisco)
-- values (503, 'Titolo 3', 2000);

select 'Disco', count(*) from disco	
union select 'Brano', count(*) from brano
union select 'Artista', count(*) from artista
union select 'Composizione', count(*) from composizione
union select 'Registrazione', count(*) from registrazione
union select 'Contiene', count(*) from contiene
