drop table if exists tessera cascade;
drop table if exists cliente cascade;
drop table if exists scontrino cascade;
drop table if exists cedi cascade;
drop table if exists articolo_cedi cascade;
drop table if exists personale cascade;
drop table if exists reparto cascade;
drop table if exists turno cascade;
drop table if exists articolo_supermercato cascade;
drop table if exists ordine_cedi cascade;
drop table if exists spesa cascade;

create table cliente(
	cf_cliente character(16) check (length(cf_cliente) = 16) primary key ,
	nome_cliente varchar(20) not null,
	cognome_cliente varchar(20) not null,
	data_nascita_cliente date not null,
	luogo_nascita_cliente varchar(20) not null,
	sesso_cliente char not null
);

create table tessera(
	 numero_tessera serial primary key,
	 data_contratto date not null,
	 punteggio_totale smallint default  0,
	 codice_cliente character(16) check (length(codice_cliente) = 16) not null unique
);
ALTER TABLE tessera
    ADD CONSTRAINT fk_tessera_cliente FOREIGN KEY (codice_cliente)
	REFERENCES cliente (cf_cliente)
	ON UPDATE cascade 
	ON DELETE cascade;
	
create table cedi(
	id_cedi serial primary key,
	nome_cedi varchar(20) not null,
	partita_iva bigint unique not null,
	citta varchar(20),
	via varchar(20),
	numero_civico varchar(20)
);

create table articolo_cedi(
	ean_cedi bigint primary key,
	nome varchar(20) not null,
	descrizione varchar(200) not null,
	prezzo_ingrosso float not null check(prezzo_ingrosso > 0),
	identificativo_cedi integer not null
);
alter table articolo_cedi
    ADD CONSTRAINT fk_articoloCedi_cedi FOREIGN KEY (identificativo_cedi)
	REFERENCES cedi (id_cedi)
	ON UPDATE cascade 
	ON DELETE cascade;


create table scontrino(
 id_scontrino serial primary key,
 data_fatturazione date not null,
 totale_spesa float check (totale_spesa > 0) not null,
 numero_tessera int,
 punteggio_parziale smallint
);
ALTER TABLE scontrino
    ADD CONSTRAINT fk_scontrino_tessera FOREIGN KEY (numero_tessera)
	REFERENCES tessera (numero_tessera)
	ON UPDATE cascade 
	ON DELETE set null;
	
	
create table personale(
	cf_personale character(16) primary key,
	nome varchar(20) not null,
	cognome varchar(20) not null,
	data_nascita date not null,
	luogo_nascita varchar(20) not null,
	sesso char not null,
	telefono char(10) not null,
	cf_responsabile character(16) check(cf_responsabile <> cf_personale)
);	
alter table personale
	add constraint fk_personale_responsabile foreign key (cf_responsabile) references personale(cf_personale)  on delete restrict on update cascade;
alter table personale
    alter constraint fk_personale_responsabile DEFERRABLE INITIALLY IMMEDIATE;



create table reparto(
	tipologia_rep varchar(20) primary key,
	descrizione varchar(200) not null,
	cf_responsabile character(16) not null unique,
);
alter table reparto
	add constraint fk_reparto_personale
	foreign key (cf_responsabile)
	references personale(cf_personale) on update cascade on delete restrict ;
	

create table turno(
	cf_addetto character(16) references personale (cf_personale) on update cascade on delete no action,
	reparto varchar(20) references reparto (tipologia_rep) on update cascade on delete no action,
	ora_inizio_turno time without time zone,
	ora_fine_turno time without time zone,
	data_turno date,
	primary key(cf_addetto,reparto,data_turno)
);

create table articolo_supermercato(
	ean bigint primary key check(length(cast(ean as varchar)) = 13),
	nome varchar(20) not null,
	descrizione varchar(200) not null,
	sconto decimal check ((sconto = 0.00 and is_offerta = False) OR ((sconto > 0.10 AND sconto < 0.70) and is_offerta = True)),
	is_offerta boolean default False,
	prezzo_vendita float default 0.00 check (prezzo_vendita >= 0.00),
	disponibilità integer not null check (disponibilità >= 0),
	ordinato boolean not null check ((ordinato = True and disponibilità = 0) OR (ordinato = False and disponibilità > 0)),
    reparto varchar(20) references reparto (tipologia_rep) on update cascade on delete restrict
);


create table ordine_cedi(
	ean_art bigint check(length(cast(ean_art as varchar)) = 13) references articolo_supermercato (ean) on delete no action on update  no action,
	id_cedi integer references cedi (id_cedi) on delete no action on update cascade,
	data_ordine date,
	quantita_ordine integer default 1000 check(quantita_ordine > 0),
	is_evaso boolean default False,
	primary key(ean_art,data_ordine,id_cedi)
);
CREATE OR REPLACE Function insertarticolo()
  RETURNS trigger AS $BODY$
DECLARE
	prezzo_supermercato float;
	random_n float;
	random_sconto float := random();
	prezzo_scontato float;
BEGIN
   IF NEW.is_evaso is True THEN
	   random_n = random()::float;
	   select prezzo_ingrosso into prezzo_supermercato from articolo_cedi where ean_cedi = new.ean_art;
	   if(random_n > 0.9) then
	        random_sconto = trunc(random_sconto::numeric,2);
			if(random_sconto > 0.69) then			
				random_sconto = random_sconto - 0.59;
			end if;	
			if(random_sconto < 0.11) then
				random_sconto = random_sconto + 0.20;
			end if;
			prezzo_scontato = prezzo_supermercato - (trunc((prezzo_supermercato::numeric),2) * random_sconto);
		   update articolo_supermercato
		   set reparto = random_utili_reparto(),sconto = random_sconto, is_offerta = True,
			   prezzo_vendita = prezzo_scontato,disponibilità = new.quantita_ordine,ordinato=false
			where ean = new.ean_art;
		else
			 update articolo_supermercato
		     set reparto = random_utili_reparto(),sconto = 0.00, is_offerta = False,
			   prezzo_vendita = trunc((prezzo_supermercato::numeric),2),disponibilità = new.quantita_ordine,ordinato=false
			where ean = new.ean_art;
		end if;
	END IF;
	return null;
END;
$BODY$ language plpgsql;

create trigger inserisciArticoloSupermercato
after update of is_evaso on ordine_cedi
for each row
execute procedure insertarticolo();	


create table spesa(
	ean_art bigint check(length(cast(ean_art as varchar)) = 13) references articolo_supermercato (ean) on delete no action on update no action,
	numero_scontrino int references scontrino(id_scontrino) on delete cascade on update cascade,
	quantita smallint not null,
	prezzo float not null,
	primary key(ean_art,numero_scontrino)
);