
--Script popolazione cliente
DO $$
declare
 nom varchar;
 cogno varchar;
 data_n date; sex char;
 tel varchar;
 city varchar;
BEGIN
for i in 1..10000 LOOP
sex = random_persona_sesso();
nom = random_persona_nome(sex);
cogno = random_persona_cognome();
data_n = random_utili_datanascita('1960-01-01','2000-01-01') ;
tel = random_persona_telefono();
city = random_utili_citta();											 
insert into cliente(cf_cliente,nome_cliente,cognome_cliente,data_nascita_cliente,luogo_nascita_cliente,sesso_cliente) 
						values (random_persona_cf(nom,cogno,cast(data_n as varchar),city,sex),
						nom,cogno,data_n,city,sex);
end loop;
end $$;	
select * from cliente;

--Script popolazione tessera
insert into tessera(data_contratto,punteggio_totale,codice_cliente)
select random_utili_data('2019-01-01','2019-12-12'),random_utili_numero(10,1000),c.cf_cliente
from cliente as c
order by random()
limit 10000;
select * from tessera;

--Script popolazione CEDI
DO $$
begin
For i in 1..30000 LOOP
	insert into cedi(nome_cedi,partita_iva,citta,via,numero_civico)
	values (random_cedi_nome(),random_cedi_piva(),random_utili_citta(),'','');
end loop;
end $$;
select * from cedi;


--Script popolazione articolo_cedi
DO $$
declare 
	descrizione varchar;

begin
For i in 1..100 LOOP
  	descrizione = random_articolo_descrizione();
	insert into articolo_cedi(ean_cedi,nome,descrizione,prezzo_ingrosso,identificativo_cedi)
	select random_articolo_ean(),random_articolo_nome(descrizione),descrizione,random_articolo_prezzo(),c.id_cedi
    from cedi as c
	order by random()
	limit 400;
end loop;
end $$;
select * from articolo_cedi;


--Script popolazione personale
DO $$
declare
 nom varchar;
 cogno varchar;
 data_n date;
 sex char;
 tel varchar;
 city varchar;
 cf character(16);
 responsable_cf character(16)[];
 num integer;
BEGIN
for i in 1..300 LOOP
sex = random_persona_sesso();
nom = random_persona_nome(sex);
cogno = random_persona_cognome();
data_n = random_utili_datanascita('1960-01-01','2000-01-01') ;
tel = random_persona_telefono();
city = random_utili_citta();
cf = random_persona_cf(nom,cogno,cast(data_n as varchar),city,sex);											 
insert into personale(cf_personale,nome,cognome,data_nascita,luogo_nascita,sesso,telefono,cf_responsabile) 
						values (cf,nom,cogno,data_n,city,sex,random_persona_telefono(),NULL);
end loop;
--settaggio responsabili
  responsable_cf = ARRAY(select cf_personale from personale order by random() limit 12);
  update personale set cf_responsabile = responsable_cf[random_utili_numero(1,12)] where cf_personale <> ALL(responsable_cf) ;  															
end $$;	

DO $$
declare
	resp_cf character(16)[];
begin
 resp_cf = ARRAY(select cf_personale from personale where cf_responsabile is NULL);
insert into reparto(tipologia_rep,descrizione,cf_responsabile) values
('Reparto 1','reparto banchi',resp_cf[1]),
('Reparto 2','reparto salumi',resp_cf[2]),
('Reparto 3','reparto gastronomia',resp_cf[3]),
('Reparto 4','reparto carne',resp_cf[4]),
('Reparto 5','reparto pane',resp_cf[5]),
('Reparto 6','reparto gelato',resp_cf[6]),
('Reparto 7','reparto amici animali',resp_cf[7]),
('Reparto 8','reparto cura persona',resp_cf[8]),
('Reparto 9','reparto casa',resp_cf[9]),
('Reparto 10','reparto cura persona',resp_cf[10]),
('Reparto 11','reparto hobby',resp_cf[11]),
('Reparto 12','reparto frutta',resp_cf[12]);
end$$;
								
						
--Script popolazione turno
do $$
declare
ora time ;
i integer := 0;
begin
LOOP
EXIT WHEN i = 3000;
ora = random_inizio_turno();
insert into turno(cf_addetto,reparto,ora_inizio_turno,ora_fine_turno,data_turno)
select personale.cf_personale,reparto.tipologia_rep,ora,random_fine_turno(ora),random_utili_data('2000-01-01','2019-12-12')
from personale,reparto
order by random()
limit 1;
i = i + 1;
end loop;
end $$;
select * from turno;





--Script popolamento articolo_super
insert into articolo_supermercato(ean,nome,descrizione,sconto,is_offerta,prezzo_vendita,disponibilità,ordinato,reparto)
select a.ean_cedi,a.nome,a.descrizione,0.00,False,0.00,0,True,random_utili_reparto()
from articolo_cedi as a
order by random()
limit 20000;


insert into ordine_cedi(ean_art,id_cedi,data_ordine,quantita_ordine,is_evaso)
select a.ean_cedi,a.identificativo_cedi,random_utili_data('2018-01-01','2019-01-01'),1000,False
from articolo_cedi as a,articolo_supermercato as s
where a.ean_cedi=s.ean and s.ordinato = True;


--Assumo che solo il 20% degli ordini sia ancora da evadere								
update ordine_cedi set is_evaso = True where random() > 0.2;

select * from articolo_supermercato where ordinato = false;
												

--Script popolazione scontrino e spesa
CREATE or replace procedure generazione_scontrino() 
LANGUAGE plpgsql
AS $$
declare
	 n_articoli integer := random_utili_numero(1,50);
	 n_scontrino integer;
	 temp_quantita integer;
	 temp_tessera int;
	 temp_punti integer;
	 duplicato smallint;
	 temp_disponibilita integer;
	 temp_ean bigint[];
	 random_n float;
BEGIN
    temp_tessera = (select numero_tessera from tessera order by random() limit 1);
	random_n = random()::float;
	if(random_n > 0.8) then
		insert into scontrino values (DEFAULT,random_utili_data('2019-01-01','2019-12-12'),0.1,temp_tessera,1);
	else
		insert into scontrino values (DEFAULT,random_utili_data('2019-01-01','2019-12-12'),0.1,NULL,0);
	end if;
	n_scontrino = (select max(id_scontrino) from scontrino);
	temp_ean = ARRAY(select ean  from articolo_supermercato where ordinato = false order by random() limit n_articoli);
    FOR i IN 1..n_articoli LOOP	        	
			temp_quantita = random_utili_numero(1,10);
			temp_disponibilita = (select disponibilità from articolo_supermercato where ean = temp_ean[i]);						   
			if( temp_disponibilita <= temp_quantita) then
				RAISE NOTICE 'disponibilità insufficiente, non è possibile acquistare articolo, è stata informato il magazzino di inviare un ordine';
				update articolo_supermercato set ordinato = True where ean = temp_ean[i];
			else
				update articolo_supermercato set disponibilità = (temp_disponibilita - temp_quantita) where ean = temp_ean[i];
				insert into spesa
				select a.ean,n_scontrino,temp_quantita, temp_quantita*a.prezzo_vendita
				from articolo_supermercato as a
				where ean = temp_ean[i];
			end if;
	 
    END LOOP;
	if(random_n > 0.8) then
			temp_punti = (select count(*) from spesa where numero_scontrino = n_scontrino);
			update scontrino set totale_spesa = trunc(((select sum(prezzo) from spesa where numero_scontrino = n_scontrino)::numeric),2),
						 punteggio_parziale = temp_punti
				where id_scontrino = n_scontrino;
			update tessera set punteggio_totale = punteggio_totale + temp_punti where numero_tessera = temp_tessera;
	else
		update scontrino set totale_spesa = trunc(((select sum(prezzo) from spesa where numero_scontrino = n_scontrino)::numeric),2)					
				where id_scontrino = n_scontrino;
	end if;	
END
$$;
									 
DO $$
begin
	For i in 1..1000 LOOP
	 call generazione_scontrino();
	end LOOP;
end$$;

select count(*) from articolo_cedi
union
select count(*) from articolO_supermercato																									   
union
select count(*) from cedi
union
select count(*) from cliente	
union
select count(*) from ordine_cedi
union
select count(*) from personale																									   
union
select count(*) from reparto
union
select count(*) from scontrino	
union
select count(*) from spesa	
union
select count(*) from tessera	
union
select count(*) from turno;	
