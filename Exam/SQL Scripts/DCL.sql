create user cedi password 'mycedi';
create user titolare_supermercato password 'mysuper';
create user dipendente password 'dip';
create user responsabile password 'admin';
create user cliente password 'mycli';


--CEDI
revoke all privileges on articolo_cedi from cedi;
revoke all privileges on cedi from cedi;
revoke all privileges on tessera from cedi;
revoke all privileges on scontrino from cedi;
revoke all privileges on cliente from cedi;
revoke all privileges on articolo_supermercato from cedi;
revoke all privileges on spesa from cedi;
revoke all privileges on reparto from cedi;
revoke all privileges on personale from cedi;
revoke all privileges on turno from cedi;
revoke all privileges on ordine_cedi from cedi;
grant insert on articolo_cedi to cedi;
grant delete on articolo_cedi to cedi;
grant select on articolo_cedi to cedi;
grant select on cedi to cedi;
grant insert on cedi to cedi;
grant update on cedi to cedi;
grant delete on cedi to cedi;
grant update on ordine_cedi to cedi;
grant select on ordine_cedi to cedi;

--titolare_supermercato

revoke all privileges on articolo_cedi from titolare_supermercato;
revoke all privileges on cedi from titolare_supermercato;
grant select on articolo_cedi to titolare_supermercato;
grant select on cedi to titolare_supermercato;

--dipendente
revoke all privileges on articolo_cedi from dipendente;
revoke all privileges on ordine_cedi from dipendente;
revoke all privileges on cedi from dipendente;
revoke all privileges on reparto from dipendente;
revoke all privileges on turno from dipendente;
grant select on turno to dipendente;
grant select on reparto to dipendente;


--responsabile

revoke all privileges on articolo_cedi from responsabile;
revoke all privileges on cedi from responsabile;
revoke all privileges on ordine_cedi from responsabile;
grant select on articolo_supermercato to responsabile;
grant select on scontrino to responsabile;

--cliente

revoke all privileges on articolo_cedi from cliente;
revoke all privileges on cedi from cliente;
revoke all privileges on tessera from cliente;
revoke all privileges on scontrino from cliente;
revoke all privileges on cliente from cliente;
revoke all privileges on articolo_supermercato from cliente;
revoke all privileges on spesa from cliente;
revoke all privileges on reparto from cliente;
revoke all privileges on personale from cliente;
revoke all privileges on turno from cliente;
revoke all privileges on ordine_cedi from cliente;
grant select on tessera to cliente;
grant select on cliente to cliente;
grant select on scontrino to cliente;
grant select on spesa to cliente;
