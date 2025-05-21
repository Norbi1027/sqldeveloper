--Listázza ki az ügyfelek azonosítóját, teljes nevét, valamint a
--megrendeléseik azonosítóját! Azok az ügyfelek is szerepeljenek az
--eredményben, akik soha nem adtak le megrendelést! A lista legyen
--vezetéknév, azon belül keresztnév, azon belül a megrendelés
--azonosítója szerint rendezve! (1.) 

select ugyfel_id, vezeteknev||' '||keresztnev teljes_nev, megrendeles_id
from hajo.s_ugyfel u left outer join hajo.s_megrendeles mr on u.ugyfel_id=mr.ugyfel
order by vezeteknev, keresztnev, megrendeles_id;

--Listázza ki a hajótípusok azonosítóját és nevét, valamint az adott
--típusú hajók azonosítóját és nevét! A hajótípusok nevét tartalmazó
--oszlop neve 'típusnév', a hajók nevét tartalmazó oszlopé pedig
--'hajónév' legyen! Azok a hajótípusok is szerepeljenek az eredményben, 
--amelyekhez egyetlen hajó sem tartozik! A lista legyen a hajótípus neve, azon
--belül a hajó neve szerint rendezve! (2.) 

select hajo_tipus_id, ht.nev típusnév, hajo_id, h.nev hajónév
from hajo.s_hajo_tipus ht left outer join hajo.s_hajo h on ht.hajo_tipus_id=h.hajo_tipus
order by ht.nev, h.nev;

--Listázza ki a 15 tonnát meghaladó rakománnyal rendelkező konténerek
--teljes azonosítóját (megrendelésazonosító és konténerazonosító),
--valamint a rakománysúlyt is 2 tizedesjegyre kerekítve! Rendezze az
--eredményt a pontos rakománysúly szerint növekvő sorrendbe! (3.) 

select megrendeles, kontener, round(rakomanysuly,2) rakomanysuly
from hajo.s_hozzarendel
where rakomanysuly>15
order by rakomanysuly;

--Listázza ki ábécérendben azoknak a kikötőknek az azonosítóját,
--amelyekbe vagy teljesített utat egy hajó az 'It_Cat azonosítójú
--kikötőből, vagy célpontja egy, az 'It_Cat' azonosítójú kikötőből
--kiinduló megrendelésnek! Egy kikötő csak egyszer szerepeljen az
--eredményben! (3) 

select distinct kikoto_id
from hajo.s_kikoto
where kikoto_id in (select erkezesi_kikoto from hajo.s_ut
                    where indulasi_kikoto='It_Cat'
                    union
                    select erkezesi_kikoto from hajo.s_megrendeles
                    where indulasi_kikoto='It_Cat')
order by kikoto_id asc;

--Listázza ki a Magyarországénál kisebb lakossággal rendelkező országok
--nevét, lakosságát, valamint a fővárosuk nevét! Azokat az országokat is
--listázza, amelyeknek nem ismerjük a fővárosát! Ezen országok esetén
--a főváros helyén a 'nem ismert' sztring szerepeljen! Rendezze az
--eredményt az országok lakossága szerint csökkenő sorrendbe! (5.) 

select o.orszag, o.lakossag, nvl(helysegnev, 'nem ismert') fovaros
from hajo.s_orszag o left outer join hajo.s_helyseg h on o.orszag=h.orszag
where o.lakossag < (select lakossag from hajo.s_orszag where orszag='Magyarország')
order by o.lakossag desc;

--Listázza ki azoknak a helységeknek az azonosítóját, országát és
--nevét, amelyeknek valamelyik kikötőjéből indult már útra az 'SC Bella'
--nevű hajó! Egy helység csak egyszer szerepeljen az eredményben! (8.) 

select distinct helyseg_id, orszag, helysegnev
from hajo.s_helyseg
where helyseg_id in (select helyseg from hajo.s_kikoto
                     where kikoto_id in (select indulasi_kikoto from hajo.s_ut
                                         where hajo in (select hajo_id
                                                        from hajo.s_hajo
                                                        where nev='SC Bella')));

--Listázza ki azoknak a megrendeléseknek az azonosítóját, amelyekért
--többet fizettek, mint a 2021 áprilisában leadott megrendelések közül
--bármelyikért! A megrendelések azonosítója mellett tüntesse fel a
--fizetett összeget is! (9.) 

select megrendeles_id, fizetett_osszeg
from hajo.s_megrendeles
where fizetett_osszeg > (select max(fizetett_osszeg)
                         from hajo.s_megrendeles
                         where to_char(megrendeles_datuma, 'yyyymm')='202104');

--Listázza ki azoknak a megrendeléseknek az azonosítóját, amelyekben
--ugyanannyi konténert igényeltek, mint valamelyik 2021 februárjában
--leadott megrendelésben! A megrendelések azonosítója mellett tüntesse fel
--az igényelt konténerek számát is! (10.) 

select megrendeles_id, igenyelt_kontenerszam
from hajo.s_megrendeles
where igenyelt_kontenerszam in (select igenyelt_kontenerszam
                                from hajo.s_megrendeles
                                where to_char(megrendeles_datuma, 'yyyymm')
                                                    ='202102');

--Listázza ki azoknak a hajóknak a nevét, a maximális súlyterhelését,
--valamint a típusának a nevét, amelyek egyetlen utat sem teljesítettek! A
--hajó nevét megadó oszlop neve hajónév', a típus nevét megadó oszlopé
--pedig 'típusnév' legyen! (11.) 

select h.nev hajónév, max_sulyterheles, ht.nev típusnév
from hajo.s_hajo h left outer join hajo.s_hajo_tipus ht on h.hajo_tipus = ht.hajo_tipus_id
where hajo_id not in (select hajo from hajo.s_ut);

select h.nev hajónév, max_sulyterheles, ht.nev típusnév
from hajo.s_hajo h left outer join hajo.s_hajo_tipus ht on h.hajo_tipus = ht.hajo_tipus_id
where hajo_id not in(select hajo from hajo.s_ut);

--Listázza ki azoknak az ügyfeleknek a teljes nevét és a származási
--országát, akiknek nincs egymilliónál nagyobb értékű megrendelésük!
--Azok az ügyfelek is szerepeljenek a listában, akiknek nem ismerjük a
--származását! Rendezze az eredményt vezetéknév, azon belül keresztnév
--szerint! (12.) 

select vezeteknev||' '||keresztnev, orszag
from hajo.s_ugyfel u left outer join hajo.s_helyseg h
on u.helyseg=h.helyseg_id
where ugyfel_id not in (select ugyfel from hajo.s_megrendeles
                        where fizetett_osszeg>1000000)
order by vezeteknev, keresztnev;

--Listázza ki a kis méretű, mobil darukkal rendelkező kikötők adatait!
--Ezeknek a kikötőknek a leírásában megtalálható a 'kikötőméret:
--kicsi', illetve a 'mobil daruk' sztring (nem feltétlenül ebben a
--sorrendben) (13.) 

select *
from hajo.s_kikoto
where leiras like '%kikötőméret: kicsi%'
and leiras like '%mobil daruk%';

--Listázza ki ábécérendben azoknak a kikötőknek az azonosítóját,
--amelyekbe legalább egy hajó teljesített utat az 'It_Cat' azonosítójú
--kikötőből, és célpontja legalább egy, az 'It_Cat' azonosítójú
--kikötőből kiinduló megrendelésnek! Egy kikötő csak egyszer szerepeljen
--az eredményben! (14.) 

select distinct kikoto_id
from hajo.s_kikoto
where kikoto_id in (select erkezesi_kikoto from hajo.s_ut 
                    where indulasi_kikoto='It_Cat'
                    intersect
                    select erkezesi_kikoto from hajo.s_megrendeles
                    where indulasi_kikoto='It_Cat')
order by kikoto_id;


--Listázza ki ábécérendben azoknak a helységeknek az azonosítóját,
--országát és nevét, ahonnan származnak ügyfeleink, vagy ahol vannak
--kikötők! Egy helység csak egyszer szerepeljen az eredményben! A lista
--legyen országnév, azon belül helységnév szerint rendezve! (15.) 

select distinct helyseg_id, orszag, helysegnev
from hajo.s_helyseg
where helyseg_id in (select helyseg from hajo.s_ugyfel
                     union
                     select helyseg from hajo.s_kikoto)
order by orszag, helysegnev;

--Listázza ki növekvő sorrendben azoknak a megrendeléseknek az
--azonosítóját, amelyekért legalább 2 milliót fizetett egy 'Yiorgos'
--keresztnevű ügyfél, és még nem történt meg a szállításuk! (19.) 

select megrendeles_id
from hajo.s_megrendeles
where fizetett_osszeg>=2000000
and ugyfel in (select ugyfel_id from hajo.s_ugyfel where keresztnev='Yiorgos')
and megrendeles_id not in (select megrendeles from hajo.s_szallit)
order by megrendeles_id;

--Listázza ki azoknak a helységeknek az azonosítóját, országát és
--nevét, amelyek lakossága meghaladja az egymillió főt, és azokét is,
--ahonnan származik 50 évesnél idősebb ügyfelünk! Egy helység csak
--egyszer szerepeljen az eredményben! A lista legyen országnév, azon belül
--helységnév szerint rendezve! (20.) 

select helyseg_id, orszag, helysegnev
from hajo.s_helyseg
where lakossag>1000000
or helyseg_id in (select helyseg from hajo.s_ugyfel
                 where months_between(sysdate, szul_dat)/12>50)
order by orszag, helysegnev;

--Melyik három ország kikötőiből induló szállításokra adták le a
--legtöbb megrendelést? Az országnevek mellett tüntesse fel az onnan
--kiinduló megrendelések számát is! (22.) 

select orszag, count(megrendeles_id) megrendelesek
from hajo.s_helyseg h inner join hajo.s_kikoto k on h.helyseg_id=k.helyseg
inner join hajo.s_megrendeles m on k.kikoto_id=m.indulasi_kikoto
group by orszag
order by count(megrendeles_id) desc
fetch first 3 rows with ties;

--Adja meg a két legkevesebb utat teljesítő olyan hajó nevét, amelyik
--legalább egy utat teljesített, és legfeljebb 10 konténert tud egyszerre
--szállítani! A hajók neve mellett tüntesse fel az általuk teljesített
--utak számát is! (24.) 

select nev, count(ut_id) utak
from hajo.s_hajo h inner join hajo.s_ut u on h.hajo_id=u.hajo
where max_kontener_dbszam<=10
group by nev
order by count(ut_id)
fetch first 2 rows only;


--Listázza ki a tíz, legtöbb igényelt konténert tartalmazó megrendelést
--leadó ügyfél teljes nevét, a megrendelés azonosítóját és az
--igényelt konténerek számát! (25.) 

select vezeteknev||' '||keresztnev teljes_nev, megrendeles_id,
igenyelt_kontenerszam
from hajo.s_ugyfel u inner join hajo.s_megrendeles m on u.ugyfel_id=m.ugyfel
order by igenyelt_kontenerszam desc fetch first 10 rows with ties;

--Adja meg az 'SC Nina' nevű hajóval megtett három leghosszabb ideig tartó
--út indulási és érkezési kikötőjének azonosítóját! (26.) 

select indulasi_kikoto, erkezesi_kikoto --erkezesi_ido-indulasi_ido hossz
from hajo.s_ut 
where hajo in (select hajo_id from hajo.s_hajo where nev='SC Nina')
order by erkezesi_ido-indulasi_ido desc nulls last
fetch first 3 rows with ties;

--Adja meg a három legtöbb utat teljesítő hajó nevét! A hajók neve
--mellett tüntesse fel az általuk teljesített utak számát is! (27.) 

select nev, count(ut_id) utak_szama
from hajo.s_hajo h left outer join hajo.s_ut u on h.hajo_id=u.hajo
group by nev 
order by count(ut_id) desc nulls last
fetch first 3 rows with ties;

--Adja meg a négy legtöbb megrendelést leadó ügyfél teljes nevét és a
--megrendeléseik számát (29.) 

select vezeteknev||' '||keresztnev nev, count(megrendeles_id) db
from hajo.s_ugyfel u left outer join hajo.s_megrendeles m on u.ugyfel_id=m.ugyfel
group by vezeteknev, keresztnev
order by db desc nulls last
fetch first 4 rows with ties;

--Listázza ki azoknak az utaknak az adatait (a dátumokat időponttal
--együtt!), amelyek nem egész percben indultak! Rendezze az eredményt az
--indulási idő szerint növekvő sorrendbe! (30.) 

select ut_id, to_char(indulasi_ido, 'yyyy.mm.dd hh24:mm:ss') indulasi_ido,
to_char(erkezesi_ido, 'yyyy.mm.dd hh24:mm:ss') erkezesi_ido, indulasi_kikoto,
erkezesi_kikoto, hajo
from hajo.s_ut
where to_char(indulasi_ido, 'ss') != '00'
order by indulasi_ido asc;

--Hozzon létre egy 's_szemelyzet' nevű táblát, amelyben a hajókon dolgozó
--személyzet adatai találhatóak! Minden szerelőnek van
--azonosítója (pontosan 10 karakteres sztring; ez az elsődleges kulcs),
--vezeték- és keresztneve (mindkettő maximum 50 karakteres sztring),
--születési dátuma (dátum), telefonszáma (maximum 20 jegyű egész szám)
--és hogy melyik hajó személyzetéhez tartozik (maximum 10 karakteres sztring),
--hivatkozással az 's_hajo' táblára! 
--Telefonszámot legyen kötelező megadni! Minden megszorítást nevezzen el! (31.)

create table s_szemelyzet(
id char(10),
vezeteknev varchar2(50),
keresztnev varchar2(50),
szuletesi_datum date,
telefonszam number(20) constraint s_sz_tf_nn not null,
hajo varchar2(10),
constraint s_sz_pk primary key(id),
constraint s_sz_ha_fk foreign key(hajo) references hajo.s_hajo(hajo_id));

--Hozzon létre egy 's_szemelyzet' nevű táblát, amelyben a hajókon dolgozó
--személyzet adatai találhatóak! Minden szerelőnek van
--azonosítója (maximum 5 jegyű egész szám; ez az elsődleges kulcs),
--vezeték- és keresztneve (mindkettő maximum 40 karakteres sztring), 
--születési dátuma (dátum), e-mail-címe (maximum 200 karakteres sztring)
--és hogy melyik hajó személyzetéhez tartozik (maximum 10 karakteres sztring),
--hivatkozássalaz 's_hajo' táblára! A vezeték- és keresztnevet, valamint a
--hajót legyen kötelező megadni! A vezeteknev, a keresztnev és születési
--dátum legyen a tábla összetett kulcsa! Minden megszorítást nevezzen el! (32.) 

create table s_szemelyzet(
id number(5) constraint s_sz_pk primary key,
vezeteknev varchar(40) constraint s_sz_vn_nn not null,
keresztnev varchar(40) constraint s_sz_kn_nn not null,
szuletesi_datum date constraint s_sz_szd_nn not null,
email_cim varchar(200),
hajo varchar(10) constraint ss_ha_nn not null,
constraint s_sz_ha_fk foreign key (hajo) references hajo.s_hajo(hajo_id),
constraint s_sz_uniq unique (vezeteknev, keresztnev, szuletesi_datum));

--Hozzon létre egy 's_kikoto_email' nevű táblát, amelyben a kikötők
--e-mail-címeit, tároljuk! Legyen benne egy
--'kikoto_id nevű oszlop (maximum 10 karakteres sztring),
--amely hivatkozik az 's_kikoto' táblára, valamint egy
--e-mail-cím, amely egy maximum 200 karakteres sztring! Egy kikötőnek több
--e-mail-címe is lehet, ezért a tábla elsődleges kulcsát a két oszlop
--együttesen alkossa! Minden megszorítást nevezzen el! (33.) 

create table s_kikoto_email(
kikoto_id varchar(10) constraint s_ke_ki_nn not null,
email_cim varchar(200) constraint s_ke_ec_nn not null,
constraint s_ke_pk primary key(kikoto_id, email_cim),
constraint s_ke_ki_fk foreign key(kikoto_id) references hajo.s_kikoto(kikoto_id));

--Hozzon létre egy 's_hajo_javitas' nevű táblát, amely a hajók javítási
--adatait tartalmazza! Legyen benne a javított hajó azonosítója, amely az
--'s_hajo' táblára hivatkozik (legfeljebb 10 karakter hosszú sztring, és
--nem lehet ismeretlen), a javítás kezdetét és végét jelző időpontok
--(dátumok), a javítás ára (legfeljebb 10 jegyű valós szám 2
--tizedesjeggyel), valamint a hiba leírása (legfeljebb 200 karakteres
--sztring)! A tábla elsődleges kulcsát a hajó azonosítója és a javítás
--kezdő dátuma együttesen alkossa! További megkötés, hogy a javítás
--vége csak a javítás kezdeténél későbbi időpont lehet! Minden
--megszorítást nevezzen el! (35.) 

create table s_hajo_javitas(
hajo varchar2(10) constraint s_hj_ha_nn not null,
javitas_kezdete date constraint s_hj_jk_nn not null,
javitas_vege date,
javitas_ara number(10,2),
hiba_leirasa varchar2(200),
constraint s_hj_pk primary key(hajo, javitas_kezdete),
constraint s_hj_ha_fk foreign key (hajo) references hajo.s_hajo(hajo_id),
constraint s_hj_ch check (javitas_vege is null or javitas_vege>javitas_kezdete));

--Hány 500 tonnánál nagyobb maximális súlyterhelésű hajó tartozik az
--egyes hajótípusokhoz? A hajótípusokat az azonosítójukkal adja meg! (35.) 

select hajo_tipus_id, count(hajo_id) db
from hajo.s_hajo_tipus ht left outer join hajo.s_hajo h on ht.hajo_tipus_id=h.hajo_tipus
and max_sulyterheles > 500
group by hajo_tipus_id;

--Törölje az 's_hajo' és az 's_hajo_tipus' táblákat! Vegye figyelembe az
--egyes táblákra hivatkozó külső kulcsokat! A feladat megoldásához több
--utasítást is használhat. (43.) 


drop table s_hajo cascade constraints;

drop table s_hajo_tipus cascade constraints;

--Törölje az 's_kikoto_telefon' tábla elsődleges kulcs megszorítását!
--(44.) 

alter table s_kikoto_telefon drop constraint s_kkt_pk;

--Bővítse az 's_kikoto_telefon' táblát egy 'email' nevű, maximum 200
--karakter hosszú sztringgel, amelynek az alapértelmezett értéke 'nem
--ismert' legyen! (49.) 

alter table s_kikoto_telefon add
(email varchar2(200) default 'nem ismert');

--Módosítsa az 's_ugyfel' tábla 'email' oszlopának maximális hosszát 50
--karakterre, az 'utca_hsz' oszlop hosszát pedig 100 karakterre! (50.) 

alter table s_ugyfel modify(
email varchar(50),
utca_hsz char(100));

--Mely hónapokban (év, hónap) adtak le legalább 6 megrendelést? A lista
--legyen időrendben! (50.) 

select to_char(megrendeles_datuma, 'yyyymm') honapok, count(*) db
from hajo.s_megrendeles
group by to_char(megrendeles_datuma, 'yyyymm')
having count(megrendeles_datuma) >= 6
order by to_date(honapok, 'yyyymm');


--Listázza ki a szíriai ügyfelek teljes nevét és telefonszámát! (53.) 

select vezeteknev||' '||keresztnev teljes_nev, telefon
from hajo.s_ugyfel
where helyseg in (select helyseg_id from hajo.s_helyseg
                  where orszag='Szíria');
                  
select vezeteknev||' '||keresztnev teljes_nev, telefon
from hajo.s_ugyfel u join hajo.s_helyseg h 
on u.helyseg = h.helyseg_id
where h.orszag ='Szíria';

--Szúrja be a 'hajo' sémából a saját sémájának 's_ugyfel táblájába az
--olaszországi ügyfeleket! (53.) 

insert into s_ugyfel (UGYFEL_ID, VEZETEKNEV, KERESZTNEV, TELEFON, EMAIL, SZUL_DAT, HELYSEG, UTCA_HSZ)
select UGYFEL_ID, VEZETEKNEV, KERESZTNEV, TELEFON, EMAIL, SZUL_DAT, HELYSEG, UTCA_HSZ
from hajo.s_ugyfel
where helyseg in (select helyseg_id from hajo.s_helyseg
                  where orszag='Olaszország');


--Szúrja be a 'hajo' sémából a saját sémájának 's_hajo' táblájába
--azokat a 'Small feeder' típusú hajókat, amelyek nettó súlya legalább
--250 tonna! (54.) 

insert into s_hajo (HAJO_ID, NEV, NETTO_SULY, MAX_KONTENER_DBSZAM, MAX_SULYTERHELES, HAJO_TIPUS)
select HAJO_ID, NEV, NETTO_SULY, MAX_KONTENER_DBSZAM, MAX_SULYTERHELES, HAJO_TIPUS
from hajo.s_hajo
where hajo_tipus in (select hajo_tipus_id from hajo.s_hajo_tipus
                     where nev='Small feeder')
and netto_suly>=250;

--Szúrja be a 'hajo' sémából a saját sémájának 's_hajo' táblájába
--azokat a 'Small feeder típusú hajókat, amelyek legfeljebb 10 konténert
--tudnak szállítani egyszerre! (55.) 

insert into s_hajo (HAJO_ID, NEV, NETTO_SULY, MAX_KONTENER_DBSZAM, MAX_SULYTERHELES, HAJO_TIPUS)
select HAJO_ID, NEV, NETTO_SULY, MAX_KONTENER_DBSZAM, MAX_SULYTERHELES, HAJO_TIPUS
from hajo.s_hajo
where hajo_tipus in (select hajo_tipus_id from hajo.s_hajo_tipus
                     where nev='Small feeder')
and max_kontener_dbszam <= 10;

--Törölje a szárazdokkal rendelkező olaszországi és líbiai kikötőket!
--Azok a kikötők rendelkeznek szárazdokkal, amelyeknek a leírásában
--szerepel a 'szárazdokk' szó! (57.) 

delete from s_kikoto
where helyseg in (select helyseg_id from hajo.s_helyseg
                  where orszag in ('Olaszország','Líbia'))
and leiras like '%szárazdokk%';



--Törölje azokat a 2021 júniusában induló utakat, amelyeken 20-nál
--kevesebb konténert szállított a hajó! (59.) 

delete from s_ut
where to_char(indulasi_ido, 'yyyymm')='202106'
and ut_id in (select ut from hajo.s_szallit
           group by ut
           having count(kontener)<20);

--Módosítsa a nagy terminálterülettel rendelkező kikötők leírását úgy,
--hogy az az elején tartalmazza a kikötő helységét is, amelyet egy
--vesszővel és egy szóközzel válasszon el a leírás jelenlegi
--tartalmától! A nagy terminálterülettel rendelkező kikötők leírásában
--szerepel a 'terminálterület: nagy,' sztring. (Figyeljen a vesszőre, a
--"nagyon nagy" területű kikötőket nem szeretnénk módosítani!) (61.) 

--kétértelmű a feladat.
--ha helység alatt az azonosítót érti
update s_kikoto set
leiras = helyseg||', '||leiras
where leiras like '%terminálterület: nagy,%';

--ha helység alatt a helység nevét érti
update s_kikoto s set
leiras = (select helysegnev from hajo.s_helyseg h
          where h.helyseg_id=s.helyseg)
         ||', '||leiras
where leiras like '%terminálterület: nagy,%';

--Alakítsa csupa nagybetűssé azon ügyfelünk vezetéknevét, aki eddig a
--legtöbbet fizette összesen a megrendeléseiért (ha több ilyen ügyfelünk
--van, akkor mindegyikükét)! (62.) 

update s_ugyfel
set vezeteknev = upper(vezeteknev)
where ugyfel_id in (select ugyfel from hajo.s_megrendeles
                    group by ugyfel
                    order by sum(fizetett_osszeg) desc nulls last
                    fetch first row with ties);

--Mennyi az egyes hajótípusokhoz tartozó hajók legkisebb nettó súlya? A
--hajótípusokat nevükkel adja meg! Csak azokat a hajótípusokat listázza,
--amelyekhez van hajónk! (65.) 

select ht.nev, min(netto_suly) suly
from hajo.s_hajo h inner join hajo.s_hajo_tipus ht on h.hajo_tipus=ht.hajo_tipus_id
group by ht.nev;

select ht.nev,min(h.netto_suly) suly
from hajo.s_hajo h join hajo.s_hajo_tipus ht
on h.hajo_tipus = ht.hajo_tipus_id
group by ht.nev;

--A francia kereskedelmi jogszabályokban nemrég bevezetett változások
--jelentős költségnövekedést okoznak a cégünk számára a francia
--megrendelések leszállítását illetően. Cégünk vezetőségének
--döntése értelmében növelje meg 15%-kal a Franciaországból származó
--ügyfeleink utolsó megrendelésiért fizetendő összeget! (67.) 

update s_megrendeles
set fizetett_osszeg = fizetett_osszeg * 1.15
where ugyfel in (select ugyfel_id from hajo.s_ugyfel
                 where helyseg in (select helyseg_id from hajo.s_helyseg
                                   where orszag='Franciaország'))
and (ugyfel, megrendeles_datuma) in (select ugyfel, max(megrendeles_datuma)
                                     from hajo.s_megrendeles
                                     group by ugyfel);

--A népességi adataink elavultak. A frissítésük egyik lépéseként
--növelje meg 5%-kal az ázsiai országok településeinek lakosságát! (68.) 

update s_helyseg set
lakossag = lakossag *1.05
where orszag in (select orszag from hajo.s_orszag where foldresz='Ázsia');

--Egy pusztító vírus szedte áldozatait Afrika nagyvárosaiban. Az
--adatbázisunk frissítése érdekében felezze meg azoknak az afrikai
--településeknek a lakosságát, amelyeknek a jelenlegi lakossága meghaladja
--a félmillió főt! (69.) 

update s_helyseg set
lakossag = lakossag * 0.5
where orszag in (select orszag from hajo.s_orszag where foldresz='Afrika')
and lakossag>500000;

--Cégünk adminisztrátora elkövetett egy nagy hibát: a 2021 júliusában
--Algeciras kikötőjéből induló utakat tévesen úgy vitte fel az
--adatbázisba, mintha azok Valenciából indultak volna. Valójában
--Valenciából egyetlen út sem indult a kérdéses időszakban. Korrigálja
--az adminisztrátor hibáját! Az egyszerűség kedvéért feltételezheti,
--hogy egyetlen 'Algeciras', illetve 'Valencia' nevű település létezik, és
--hogy mindkét város egyetlen kikötővel rendelkezik. (70.) 

update s_ut set
indulasi_kikoto = (select distinct kikoto_id from hajo.s_kikoto
                   where helyseg in (select helyseg_id from hajo.s_helyseg
                                     where helysegnev='Algeciras'))
where indulasi_kikoto = (select distinct kikoto_id from hajo.s_kikoto
                         where helyseg in (select helyseg_id from hajo.s_helyseg
                                           where helysegnev='Valencia'))
and to_char(indulasi_ido, 'yyyymm') = '202107';

--Hozzon létre nézetet, amely listázza az utak minden attribútumát,
--kiegészítve az indulási és érkezési kikötő helységnevével és
--országával! (71.) 

create view utak_mind as
select u.*, h.orszag indulasi_orszag, h.helysegnev indulasi_hely,
he.orszag erkezesi_orszag, he.helysegnev erkezesi_hely
from hajo.s_ut u 
inner join hajo.s_kikoto ki on u.indulasi_kikoto=ki.kikoto_id
inner join hajo.s_helyseg h on ki.helyseg=h.helyseg_id
inner join hajo.s_kikoto ke on ke.kikoto_id=u.erkezesi_kikoto
inner join hajo.s_helyseg he on ke.helyseg=he.helyseg_id;

--Hozzon létre nézetet, amely listázza a megrendelések összes
--attribútumát, kiegészítve az indulási és érkezési kikötő
--helységnevével és országával! (74.) 

create view megrendeles_mind as
select m.*, h.orszag indulasi_orszag, h.helysegnev indulasi_hely,
he.orszag erkezesi_orszag, he.helysegnev erkezesi_hely
from hajo.s_megrendeles m 
left outer join hajo.s_kikoto ki on m.indulasi_kikoto=ki.kikoto_id
inner join hajo.s_helyseg h on ki.helyseg=h.helyseg_id
left outer join hajo.s_kikoto ke on ke.kikoto_id=m.erkezesi_kikoto
inner join hajo.s_helyseg he on ke.helyseg=he.helyseg_id;

--Hozzon létre nézetet, amely listázza, hogy az egyes hajótípusokhoz
--tartozó hajók összesen hány utat teljesítettek! A listában szerepeljen
--a hajótípusok azonosítója, neve és a teljesített utak száma! Azokat a
--hajótípusokat is tüntesse fel az eredményben, amelyekhez egyetlen hajó
--sem tartozik, és azokat is, amelyekhez tartozó hajók egyetlen utat sem
--teljesítettek! A lista legyen a hajótípus neve szerint rendezett! (75.) 

create view utak_tipusonkent as
select hajo_tipus_id, ht.nev, count(ut_id) utak_szama
from hajo.s_hajo_tipus ht left outer join hajo.s_hajo h on ht.hajo_tipus_id=h.hajo_tipus
left outer join hajo.s_ut u on u.hajo=h.hajo_id
group by hajo_tipus_id, ht.nev;

--Hozzon létre nézetet, amely listázza, hogy az egyes kikötőknek hány
--telefonszáma van! A lista tartalmazza a kikötők azonosítóját, a
--helységük nevét és országát, valamint a telefonszámaik számát!
--Azokat a kikötőket is tűntesse fel az eredményben, amelyeknek egyetlen
--telefonszáma sincs! (76.) 

create view kikoto_telefonszam_db as
select k.kikoto_id, helysegnev, orszag, count(telefon) telefonszam_db
from hajo.s_kikoto k left outer join hajo.s_kikoto_telefon kt on k.kikoto_id=kt.kikoto_id
inner join hajo.s_helyseg h on h.helyseg_id=k.helyseg
group by k.kikoto_id, helysegnev, orszag;

--Hozzon létre nézetet, amely listázza, hogy az egyes kikötőkbe hány út
--vezetett! A lista tartalmazza a kikötők azonosítóját, a helységük
--nevét és országát, valamint az utak számát azokat a kikötőket is
--tüntesse fel az eredményben, amelyekbe egyetlen út sem vezetett! (78.) 

create view erkezesi_utak_szama as
select kikoto_id, helysegnev, orszag, count(ut_id) utak_szama
from hajo.s_kikoto k left outer join hajo.s_ut u on k.kikoto_id=u.erkezesi_kikoto
inner join hajo.s_helyseg h on h.helyseg_id=k.helyseg
group by kikoto_id, helysegnev, orszag;

--Melyik ázsiai településeken található kikötő? Az eredményben az
--ország- és helységneveket adja meg, országnév, azon belül helységnév
--szerint rendezve! (79.) 

select orszag, helysegnev
from hajo.s_helyseg
where orszag in (select orszag from hajo.s_orszag where foldresz='Ázsia')
and helyseg_id in (select helyseg from hajo.s_kikoto)
order by orszag, helysegnev;


select orszag,helysegnev
from hajo.s_kikoto k join hajo.s_helyseg h
on k.helyseg = h.helyseg_id
where helyseg_id in(select helyseg from hajo.s_kikoto) and
h.orszag in (select o.orszag
from  hajo.s_orszag o
where o.foldresz = 'Ázsia'
group by o.orszag)
order by orszag,helysegnev;

--Hozzon létre nézetet, amely listázza, hogy az egyes kikötők hány
--megrendelésben szerepeltek célpontként! A lista tartalmazza a kikötők
--azonosítóját, a helységük nevét és országát valamint a
--megrendelések számát! Azokat a kikötőket is tüntesse fel az
--eredményben, amelyek nem fordultak elő egyetlen megrendelés
--célpontjaként sem! (80.) 

create view megrendelesek_kikotonkent as
select kikoto_id, helysegnev, orszag, count(megrendeles_id) megrendelesek_szama
from hajo.s_kikoto k 
left outer join hajo.s_megrendeles m on k.kikoto_id=m.erkezesi_kikoto
inner join hajo.s_helyseg h on h.helyseg_id=k.helyseg
group by kikoto_id, helysegnev, orszag;

--Hozzon létre nézetet, amely megadja a legnagyobb forgalmú kikötő(k)
--azonosítóját, helységnevét és országát! A legnagyobb forgalmú
--kikötő az, amelyik a legtöbb út indulási vagy érkezési kikötője
--volt. (81.) 

create view legnagyobb_forgalmu_kikoto as
select kikoto_id, helysegnev, orszag
from hajo.s_kikoto k inner join hajo.s_helyseg h on k.helyseg=h.helyseg_id
left outer join hajo.s_ut u on u.indulasi_kikoto=k.kikoto_id or u.erkezesi_kikoto=k.kikoto_id
group by kikoto_id, helysegnev, orszag
order by count(ut_id) desc nulls last
fetch first row with ties;

--Hozzon létre nézetet, amely megadja annak a kikötőnek az azonosítóját,
--helységnevét és országát, amelyikből kiinduló utakon szállított
--konténerek összsúlya a legnagyobb! Ha több ilyen kikötő is van, akkor
--mindegyiket listázza! (83.) 

create view max_onsuly_indulasi as
select kikoto_id, helysegnev, orszag, sum(rakomanysuly)
from hajo.s_kikoto k
inner join hajo.s_helyseg h on k.helyseg=h.helyseg_id
inner join hajo.s_ut u on u.indulasi_kikoto=k.kikoto_id
inner join hajo.s_szallit sz on sz.ut=u.ut_id
inner join hajo.s_hozzarendel hr on hr.megrendeles=sz.megrendeles
and hr.kontener=sz.kontener
group by kikoto_id, helysegnev, orszag
order by sum(rakomanysuly) desc nulls last
fetch first row with ties;


--Hozzon létre nézetet, amely megadja annak a kikötőnek az azonosítóját,
--helységnevét és országát, amelyikbe tartó utakon szállított
--konténerek összsúlya a legnagyobb! Ha több ilyen kikötő is van, akkor
--mindegyiket listázza! (84.) 

create view max_onsuly_erkezesi as
select kikoto_id, helysegnev, orszag
from hajo.s_kikoto k
inner join hajo.s_helyseg h on h.helyseg_id=k.helyseg
inner join hajo.s_ut u on u.erkezesi_kikoto=k.kikoto_id
inner join hajo.s_szallit sz on sz.ut=u.ut_id
inner join hajo.s_hozzarendel hr on hr.kontener=sz.kontener 
and hr.megrendeles=sz.megrendeles
group by kikoto_id, helysegnev, orszag
order by sum(rakomanysuly) desc nulls last
fetch first row with ties;

--Hozzon létre nézetet, amely megadja azoknak az utaknak az adatait, amelyeken
--a rakomány súlya (a szállított konténerek és a rakományaik
--összsúlya) meghaladja a hajó maximális súlyterhelését! Az út adatai
--mellett tüntesse fel a hajó nevét és maximális súlyterhelését,
--valamint a rakomány súlyát is! (85.) 

create view maxnal_tobb as
select ut_id, indulasi_ido, erkezesi_ido, indulasi_kikoto, erkezesi_kikoto,
hajo, max_sulyterheles, (2*count(sz.kontener) + sum(rakomanysuly)) rakomany_sulya
from hajo.s_ut u inner join hajo.s_hajo h on u.hajo=h.hajo_id
inner join hajo.s_szallit sz on sz.ut=u.ut_id
inner join hajo.s_hozzarendel hr on sz.kontener=hr.kontener
and sz.megrendeles=hr.megrendeles
group by hajo, ut_id, indulasi_ido, erkezesi_ido, indulasi_kikoto, erkezesi_kikoto,
max_sulyterheles
having (2*count(sz.kontener) + sum(rakomanysuly))>max_sulyterheles;

--Hozzon létre nézetet, amely megadja azoknak az utaknak az adatait, amelyeken
--a rakomány súlya (a szállított konténerek és a rakományaik
--összsúlya) nem haladja meg a hajó maximális súlyterhelésének a felét!
--Az út adatai mellett tüntesse fel a hajó nevét, és maximális
--súlyterhelését, valamint a rakomány súlyát is! (86.) 

create view nem_tulterhelt_utak as
select ut_id, indulasi_ido, erkezesi_ido, indulasi_kikoto, erkezesi_kikoto, hajo,
h.nev, max_sulyterheles, (2*count(sz.kontener)+sum(rakomanysuly)) rakomany_sulya
from hajo.s_ut u 
inner join hajo.s_hajo h on h.hajo_id=u.hajo
inner join hajo.s_szallit sz on sz.ut=u.ut_id
inner join hajo.s_hozzarendel hr on hr.megrendeles=sz.megrendeles
and hr.kontener=sz.kontener
group by ut_id, max_sulyterheles,
indulasi_ido, erkezesi_ido, indulasi_kikoto, erkezesi_kikoto, hajo, h.nev
having (2*count(sz.kontener)+sum(rakomanysuly))<=max_sulyterheles*0.5;

--Melyik hajó(k) indult(ak) útra utoljára? Listázza ki ezeknek a hajóknak a
--nevét, azonosítóját, az indulási és érkezési kikötők
--azonosítóját, valamint az indulás dátumát és idejét! (87.) 

select nev, indulasi_kikoto, erkezesi_kikoto, max(indulasi_ido),
to_char(indulasi_ido, 'yyyy.mm.dd hh24:mm:ss') indulas_datuma
from hajo.s_hajo h inner join hajo.s_ut u on h.hajo_id=u.hajo
where indulasi_ido in (select indulasi_ido from hajo.s_ut
                       order by indulasI_ido desc nulls last
                       fetch first row with ties)
group by nev, indulasi_kikoto, erkezesi_kikoto, indulasi_ido;
 

--Hozzon létre nézetet, amely megadja annak a megrendelésnek az adatait,
--amelynek a teljesítéséhez a legtöbb útra volt szükség! Ha több ilyen
--megrendelés is van, akkor mindegyiket listázza! (88.) 

create view legtobb_utu_rendeles as
select *
from hajo.s_megrendeles
where megrendeles_id in (
            select megrendeles_id
            from hajo.s_megrendeles m 
            inner join hajo.s_szallit sz on sz.megrendeles=m.megrendeles_id
            group by megrendeles_id
            order by count(distinct ut) desc nulls last 
            fetch first row with ties);

--Adjon hivatkozási jogosultságot a 'panovics' nevű felhasználónak az ön
--'s_ut' táblájának 'indulasi_ido' és 'hajo' oszlopaira! (92.) 

grant references (indulasi_ido, hajo) on s_ut to panovics;

--Adjon módosítási jogosultságot a
--'panovics' nevű felhasználónak az ön 's_ugyfel' táblájára! (94.) 

grant update on s_ugyfel to panovics;

--Adjon módosítási jogosultságot a panovics' nevű felhasználónak az ön
--'s_ugyfel' táblájának a 'vezeteknev' és 'keresztnev' oszlopaira! (94.) 

grant update (vezeteknev, keresztnev) on s_ugyfel to panovics;

--Vonja vissza a lekérdezési jogosultságot a 'panovics' nevű
--felhasználótól az ön 's_ut' táblájáról! (96.) 

revoke select on s_ut from panovics;

--Az 'It_Cat' azonosítójú kikötőből induló legkorábbi út/utak melyik
--kikötő(k)be indult(ak)? Adja meg az érkezési kikötő(k) azonosítóját,
--valamint a helységének és országának a nevét! (97.) 

select kikoto_id, helysegnev, orszag
from hajo.s_kikoto k inner join hajo.s_helyseg h on k.helyseg=h.helyseg_id
where kikoto_id in (select erkezesi_kikoto from hajo.s_ut
                    where indulasi_kikoto = 'It_Cat'
                    order by indulasi_ido asc nulls last
                    fetch first row with ties);

--Vonja vissza a törlési és módosítási jogosultságot a 'panovics' nevű
--felhasználótól az ön 's_kikoto' táblájáról! (98.) 

revoke delete, update on s_kikoto from panovics;

--Vonja vissza a törlési jogosultságot a 'panovics' nevű felhasználótól
--az ön 's_orszag' táblájáról! (99.) 

revoke delete on s_orszag from panovics;

--Vonja vissza a beszúrási jogosultságot minden felhasználótól az ön
--'s_megrendeles' táblájáról! (100.)

revoke insert on s_megrendeles from PUBLIC;
