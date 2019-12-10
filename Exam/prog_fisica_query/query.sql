--
---
----
----------ATTENZIONE ESSENDO I DATI GENERATI RANDOMICAMENTE POTREBBE CAPITARE CHE LE QUERY RITONARNO TABELLE VUOTE
-----
-----
-------

--QUERY 1 :
--SELEZIONARE REPARTO E NUMERO ARTICOLI ACQUISTATI DI QUEL REPARTO DA PARTE DEL PRIMO CLIENTE REGISTRATO

create view v1 as
	select codice_cliente
	from tessera as t
	where numero_tessera = (select min(numero_tessera) from tessera);

create view v2 as
	select t.numero_tessera
	from tessera, v1
	where t.codice_cliente = v1.codice_cliente;
	
create view v3 as
	select s.id_scontrino
	from scontrino as s inner join v2 as v
	on  v.numero_tessera=s.numero_tessera;
	
create view v4 as
	select spesa.ean_art 
	from spesa inner join v3
	on v3.id_scontrino = spesa.numero_scontrino;

select art_sup.reparto,count(*)  as quantita
from articolo_supermercato as art_sup inner join v4
on v4.ean_art = art_sup.ean
group by (art_sup.reparto)
order by(count(*)) asc;

--QUERY 2:
--CALCOLARE IL NUMERO DI ARTICOLI ACQUISTATI PER REPARTO A PARTIRA DA UNA DETERMINATA DATA

create view v1_query2 as
	select id_scontrino
	from scontrino
	where data_fatturazione < '2019-03-02';
	
create view v2_query2 as
	select spesa.ean_art as ean,sum(spesa.quantita) as quantita
	from spesa inner join  v1_query2
	on v1_query2.id_scontrino = spesa.numero_scontrino
	group by(spesa.ean_art);
	
select art_sup.reparto , sum(v2_query2.quantita) as articoli_acquistati
	from v2_query2 inner join articolo_supermercato as art_sup
	on v2_query2.ean = art_sup.ean
	group by(art_sup.reparto);
	
	
--QUERY 3 visualizzare il personale presente nella giornata con più incassi

create view v1_query3 as
	select data_fatturazione,sum(totale_spesa) as totale
	from scontrino
	group by(data_fatturazione);

create view v2_query3 as
	select data_fatturazione,totale as totale
	from v1_query3
	where totale >= ALL(select totale from v1_query3);

create view v3_query3 as
	select cf_addetto
	from  turno inner join v2_query3 --posso farlo perchè da quella vista esce solo una riga
	on v2_query3.data_fatturazione = data_turno;

select personale.nome,personale.cognome
from personale inner join v3_query3
on personale.cf_personale = v3_query3.cf_addetto;

	
