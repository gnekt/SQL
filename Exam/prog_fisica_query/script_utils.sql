
--Funzione di utilità che genera randomicamente un numero compreso tra <low> e <max>
create or replace function random_utili_numero(low int,max_n int) returns int as
$$
	begin
	return floor(random() * (max_n - low + 1) + low)::int;
	end;
$$ language plpgsql;

create or replace function random_utili_data(min date,max date) returns date as
$$
declare
  born date ;
begin
  born = CURRENT_DATE - (random() * (CURRENT_DATE - $1))::int;
  return born;
end;
$$ language plpgsql;


--Blocco funzioni per la generazione delle informazioni relative a 
--Cognome, Nome, Data di Nascita, Codice Fiscale,Sesso
--Funzione che genere randomicamente un cognome

--PERSONA
create or replace function random_persona_cognome() returns text as
$$
	declare
	chars text[] := '{Rossi,Russo,Ferrari,Esposito,Bianchi,Romano,
	Colombo,Ricci,Marino,Greco,Bruno,Gallo,Conti,De Luca,Mancini,
	Costa,Giordano,Rizzo,Lombardi,Moretti}';
	j integer;
	begin
	j = cast ((random() * (array_length(chars, 1)-1) + 1) as int);
	return chars[j];
	end;
$$ language plpgsql;

--Funzione per il nome
create or replace function random_persona_nome(sex char) returns text as
$$
	declare
	man text[] := '{Francesco,
					Leonardo,Alessandro,Lorenzo,Mattia,Andrea,Gabriele,Riccardo,Matteo,Tommaso,Edoardo,Federico,Giuseppe,Antonio,Diego,Davide,Christian,
					Nicolò,Giovanni,Samuele}';
	girl text[] :=	'{Sofia,Giulia,Aurora,Alice,Ginevra,Emma,Giorgia,Greta,Martina,Beatrice,Anna,Chiara,Sara,Nicole,Ludovica,Gaia,Matilde,Vittoria,Noemi,Francesca}';
	j integer;
	begin
	if sex = 'M' then
		j = cast ((random() * (array_length(man, 1)-1) + 1) as int);
		return man[j];
	else
		j = cast ((random() * (array_length(girl, 1)-1) + 1) as int);
		return girl[j];
	end if;
	end;
$$ language plpgsql;

--Funzione per la data di nascita
CREATE OR REPLACE FUNCTION random_utili_datanascita(min date,max date) RETURNS date AS 
$$
declare
  born date ;
begin
  born = CURRENT_DATE - (random() * (CURRENT_DATE - $1))::int;
  if born > max then
	born = born - interval '9000 day';
  end if;
  return born;
end;
$$ LANGUAGE plpgsql;

--Funzione per la generazione di un codice fiscale casuale
create or replace function random_persona_cf(
 name_s varchar(20),
 surname varchar(20),
 birthdate varchar(20),
 location_born varchar(20),
 sex varchar(1)
 ) returns character(16) AS
 $$
 declare
	cf_name varchar(20) = upper(substring( $1 from 1 for 2));
	cf_surname varchar(3) = upper(substring( $2 from 1 for 2));
	cf_bd_d varchar(20) = upper(substring( $3 from 1 for 2));
	cf_bd_y varchar(20) = upper(substring( $3 from 9 for 2));
	cf_lb varchar(3) = upper(substring( $4 from 1 for 2));
	cf_sex int;
    temp_cf varchar;
begin
	if sex = 'M' then
       cf_sex = 0;
    else
       cf_sex = 1;
	end if;	
	temp_cf = cf_name ||cast( (floor(random()*(9-1+1))+1 ) as varchar(1))|| cf_bd_d || cf_surname ||cast( (floor(random()*(9-1+1))+1 ) as varchar(1))|| cf_sex || cf_lb || cf_bd_y || cast( (floor(random()*(9-1+1))+10 ) as varchar(1)) || upper(substring($4 from 3 for 2));
    --In caso di un eventuale collisione, non siamo l' anagrafe!
	--questo è necessario perchè l'agenzia delle entrate può gestire gli omocodici attraverso l'uso di un algoritmo, usando noi funzioni random aumentando il volume c'è il 
	--grosso rischio di incorrere in un errore di duplicazione chiave
	if (select count(*) from cliente where cf_cliente=temp_cf) > 0 then 
	   temp_cf = cf_bd_d ||cast( (floor(random()*(9-1+1))+1 ) as varchar(1))|| cf_name || cf_sex ||cast( (floor(random()*(9-1+1))+1 ) as varchar(1))|| cf_surname || cf_lb || cf_bd_y || cast( (floor(random()*(9-1+1))+10 ) as varchar(1)) || upper(substring($4 from 3 for 2));
    end if;
	return temp_cf;
end;
$$ language plpgsql;

--Funzione per la generazione di una città casuale
create or replace function random_utili_citta() returns varchar AS
$$
declare chars text[] := '{	Agrigento,Alessandria,Ancona,Aosta,Arezzo,
							Ascoli Piceno,Asti,Avellino,Bari,Barletta,Andria,Trani,Belluno,Benevento,Bergamo,Biella,Bologna,Bolzano,
							Brescia,Brindisi,Cagliari,Caltanissetta,Campobasso,Carbonia-Iglesias,Caserta,Catania,Catanzaro,Chieti,Como}';
j integer;
begin
	j = cast ((random() * (array_length(chars, 1)-1) + 1) as int);
	return chars[j];
end;
$$ language plpgsql;

--Funzione per la generazione di un sesso casuale
create or replace function random_persona_sesso() returns char as
$$
declare
	n integer;
begin
    n = floor(random() * (2-1+1)) +1;
	if n=1 then
	 return 'M';
	else
	 return 'F';
	end if;
end;
$$ language plpgsql;

--Funzione per la generazione di un telefono
create or replace function random_persona_telefono() returns varchar as
$$
declare
	prefisso text[] := '{334,338,327,352,0823}';
    c integer;
	telefono varchar;
begin
	c = floor(random() * (5-1+1))+1;
	if length(prefisso[c]) > 3 then
		telefono = prefisso[c] || cast(floor(random() * (999999-100000+1))+1 as varchar);
	else
		telefono = prefisso[c] || cast(floor(random() * (9999999-100000+1))+1 as varchar);
	end if;
	if length(telefono) <> 10 then
	   Loop
	   EXIT when length(telefono) = 10;
	   telefono = telefono || '0';
	   end loop;
	end if;  
	return telefono;
end;
$$ language plpgsql;


-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
--TURNO

--Blocco funzioni per la generazione delle informazioni relative a 
--all' ora di inizio e di fine TURNO

--Funzione generazione inizio turno
create or replace function random_inizio_turno() returns time as
$$
declare
ore text[] := '{00,04,08,12,16,20}';
minuti text[] := '{00,30}';
n integer;
minu integer;
begin
 n = random_utili_numero(1,5);
 minu = random_utili_numero(1,2);
 return ore[n]||':'||minuti[minu]||':'||'00';
end;
$$ language plpgsql;


create or replace function random_fine_turno(inizio time ) returns time as
$$
begin
	return inizio + interval '4 hours';
end;
$$ language plpgsql;
	



-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------

--Blocco funzioni per la generazione di informazioni relative al CEDI
-- nome,partita iva, posizione geografica

--Funzione generazione nome cedi
create or replace function random_cedi_nome() returns varchar as
$$
declare
	azienda text[] := '{Crai,Sigma,Famila,Deco,Penny,Md,San Benedetto,Lete,Milka,Mulino Bianco,Barilla,Voiello,Schar,Santo Stefano,Coca Cola}';
    numero_sede int := floor(random() * (5-1+1))+1;
begin
	return azienda[(floor(random() * (15-1+1))+1)] || cast(numero_sede as varchar);
end;
$$ language plpgsql;


create or replace function random_cedi_piva() returns bigint as
$$
declare
	piva bigint := floor(random() * (99999999999-10000000000+1))+1;
begin
	return piva;
end;
$$ language plpgsql;

--Funzione


-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
--Blocco funzioni per la generazione casuale delle informazioni relative all' articolo lato cedi

--Funzione che genera randomicamente un ean (da vincoli sulla realtà ha minimo 8 cifre
-- e massimo 13
create or replace function random_articolo_ean() returns bigint as
$$
declare 
	pre_elab varchar;
	post_elab bigint;
begin
	pre_elab =  floor(random() * (1000000000000 - 10000000 + 1) + 10000000)::varchar;
    if length(pre_elab) <> 13 then
	   Loop
	   EXIT when length(pre_elab) = 13;
	   pre_elab = pre_elab || random_utili_numero(0,9);
	   end loop;
	end if; 
	post_elab = cast(pre_elab as bigint);
	
	return post_elab;								 
end;
$$ language plpgsql;

--Funzione generazione descrizione alimento
create or replace function random_articolo_descrizione() returns varchar as
$$
declare
	generics text[] := '{alimento da banco , alimento da frigo, generico food, prodotto commestibile,
                         Alimento di originale Animale, Alimento di origine Vegetale, Bevande,
						 Alimento dietetico per persone sane,Alimento per persone con particolari condizioni patologiche,
						 alimento addizionato con ingredienti di origine naturale che possiedono particolari funzioni preventive e/o protettive,
						 Prodotto di 1° Gamma: conservato attraverso trattamento termico,Prodotto di 2° Gamma: congelato,
						 alimento biologico}';
	
   j integer; 
begin
   j = cast ((random() * (array_length(generics, 1)-1) + 1) as int);
   return generics[j];
end;
$$ language plpgsql;

--Funzione generazione nome articolo
create or replace function random_articolo_nome(type_food varchar) returns varchar as
$$
declare
	banco text[] := '{kitkat,pasta de cecco,pasta barilla,marmellata,carta igienica,fazzoletti,shampoo,bagno schiuma,detergente intimo,amica chips,milka,kinder fetta a latte,
						nutella,fonzies}';
	frigo text[] := '{salame,prosciutto,mozzarella,latte,formaggio,grana padana,gorgonzola,wurstel,pasta sfoglia,yougurt,lievito,jocca,ricotta,mortadella,philadelphia}';
	bevande text[] := '{coca cola, sprite, fanta, chinotto, gatorade, powerade, red bull,vino, birra, acqua minerale, acqua gassata }';
	senza_glutine text[] := '{pane senza glutine,pizza senza glutine,pasta senza glutine}';
	generics text[] := '{tonno,angus,bistecca,melanzane,pomodori,insalata,zucchine,finocchio,scottona,vitello,girello,pollo,beef,carne kobe,spinaci,spinacine}';
	returned_name varchar;
	i integer;
begin
	CASE type_food
		WHEN 'alimento da banco' THEN
	        i = cast ((random() * (array_length(banco, 1)-1) + 1) as int);
            returned_name = banco[i];
		WHEN 'alimento da frigo' THEN
            i = cast ((random() * (array_length(frigo, 1)-1) + 1) as int);
            returned_name = frigo[i];
		WHEN 'Bevande' THEN
            i = cast ((random() * (array_length(bevande, 1)-1) + 1) as int);
            returned_name = bevande[i];
		when 'Alimento per persone con particolari condizioni patologiche' then
			i = cast ((random() * (array_length(senza_glutine, 1)-1) + 1) as int);
            returned_name = senza_glutine[i];
		ELSE
			i = cast ((random() * (array_length(generics, 1)-1) + 1) as int);
            returned_name = generics[i];
 END CASE;
 return returned_name;
end;
$$ language plpgsql;

--Funzione generazione prezzo
create or replace function random_articolo_prezzo() returns decimal as
$$
declare
	pre_elab decimal;
begin
	pre_elab = random() * (9.999-0.999)+0.999;
	return trunc(pre_elab,3);
end;
$$ language plpgsql;


create or replace function random_utili_reparto() returns varchar as
$$
begin
   return (select tipologia_rep from reparto order by random() limit 1);
end;
$$ language plpgsql;