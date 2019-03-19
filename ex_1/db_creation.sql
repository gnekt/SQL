drop table if exists CONTIENE cascade;
drop table if exists REGISTRAZIONE cascade;
drop table if exists COMPOSIZIONE cascade;
drop table if exists DISCO cascade;
drop table if exists BRANO cascade;
drop table if exists ARTISTA cascade;

create table ARTISTA (
  IDARTISTA INT primary key,
  COGNOME VARCHAR(20) not null,
  NOME VARCHAR(20) null);
  
create table BRANO (
  IDBRANO INT primary key,
  TITOLOBRANO VARCHAR(20) not null,
  ANNOCOMPOSIZIONE INT null);

create table COMPOSIZIONE (
  IDBRANO INT references BRANO (IDBRANO) on delete restrict on update restrict,
  IDARTISTA INT references ARTISTA (IDARTISTA)on delete restrict on update restrict,
  primary key (IDBRANO, IDARTISTA));
			   
create table DISCO (
  IDDISCO INT primary key,
  TITOLODISCO VARCHAR(20) not null,
  ANNODISCO INT null);

create table REGISTRAZIONE (
  IDBRANO INT references BRANO (IDBRANO) on delete restrict on update restrict,
  IDARTISTA INT references ARTISTA (IDARTISTA) on delete restrict on update restrict,
  ANNOREGISTRAZIONE INT NULL, 
  primary key (IDBRANO, IDARTISTA));
	
create table CONTIENE (
  IDDISCO INT references DISCO (IDDISCO) on delete restrict on update restrict,
  IDBRANO INT,
  IDARTISTA INT,
  primary key (IDDISCO, IDBRANO, IDARTISTA),
  foreign key (IDBRANO, IDARTISTA) 
	references REGISTRAZIONE (IDBRANO, IDARTISTA) 
	on delete restrict on update restrict);
			   
create or replace function random_string(minLength integer, maxLength integer) returns text as 
$$
declare
  chars text[] := '{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z}';
  result text := '';
  i integer; j integer; L integer;
begin
  if minLength > maxLength then
    raise exception 'minLength >= maxLength';
  end if; 
 L = minLength + cast((maxLength-minLength)*random() as int);
 for i in 1..L loop
  j = cast ((random() * (array_length(chars, 1)-1) + 1) as int);
  result := result || chars[j];
 end loop;
 return result;
end;
$$ language plpgsql; 


create or replace function random_name() returns text as 
$$
declare
  chars text[] := '{
  	Antonio,Francesco,Gianna, Roberto, Vincenzo, Paolo,
	Carmine,Pietro,Luigi,Rossella,Anna,Giovanni,Sergio,Valentina,
	Federico,Tiziano,Loredana,Ettore,Massimo,Mario,Vittorio,Stefano,
	Nicola, Angelo,Simone}';
  j integer;
begin
 j = cast ((random() * (array_length(chars, 1)-1) + 1) as int);
 return chars[j];
end;
$$ language plpgsql; 

create or replace function random_surname() returns text as 
$$
declare
  chars text[] := '{
  	Bianchi,Rossi,Esposito,Paolino,Russo,Vento,Chianese,
	Picariello,Moscato,De Santo,Marcelli,Canonico,Barrasso,
	Galdi,Coppola,Faruolo,Bennato,Guccini,Paoli,
	Battiato,Cipriano,Smith,Wesson,CaioSempronio,d''Acierno}';
  j integer;
begin
 j = cast ((random() * (array_length(chars, 1)-1) + 1) as int);
 return chars[j];
end;
$$ language plpgsql; 
