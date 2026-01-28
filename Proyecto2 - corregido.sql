--1: creado esquema, sacando diagrama en la pestaña public--

--2: peliculas con clasificación R--
select "title" , "rating"
from "film"
where "rating" = 'R';

--3: actor_id entre 30-40--
select "actor_id", Concat("first_name",' ',"last_name") as "name"
from "actor"
where "actor_id" between '30' and '40';

--4: peliculas idioma original --
/*No está bien la BBDD, en la original_language_id todos los valores son nulos
*y en el language_id son todos el valor 1.
*He creado la siguiente consulta para buscar peliculas con el id 2, 3... y no aparece ninguna, solo la 1 */
select *
from  "film"
where "language_id" = "original_language_id";

--5: ordenar peliculas por duración ascendente--
select "title", "length"
from "film"
order by "length" asc;

--6: nombre y apellido actores con apellido Allen--
select "first_name","last_name"
from "actor"
where "last_name" Ilike '%Allen%';

--7: cantidad total peliculas por clasificacion--
select "rating", count (*) as "nº_peliculas"
from "film"
group by "rating";

--8: películas PG-13 o >3 horas--
select "title", "length", "rating"
from "film"
where "rating"='PG-13'
or "length" > 180;

--9: variabilidad reemplazar las peliculas--
select round(variance ("replacement_cost"),2) as "variabilidad reemplazo"
from "film";

--10: mayor y menor película por duración"
select min("length") as "menor_duración", max ("length") as "mayor_duración" 
from "film";

--11: coste antepenúltimo alquiler ordenado por día--
/*He entendido como ordenación de día la fecha de devolución, quito las nulas, 
*entendiendo que aún no se han devuelto y no podemos saber el precio*/
select p."rental_id", p."amount", r."return_date"
from "payment" as p
inner join "rental" as r
on p. "rental_id" = r. "rental_id"
where r."return_date" is not null
order by r."return_date" desc
offset 1
limit 1;

--12: título de las peliculas que no sea NC-17 ni G--
select "title", "rating"
from "film"
where "rating" <> 'NC-17' 
and "rating" <>'G';

--13: promedio duración película por clasificación--
select "rating", round(avg ("length"),0) as "duración_media"
from "film"
group by "rating";

--14: peliculas duración mayor 180 min--
select "title", "length"
from "film"
where "length" > 180
order by "length" asc;

--15: ingresos empresa--
select round(sum ("amount"),0) as "ingresos_totales"
from "payment";

--16: 10 clientes con mayor valor id--
select*
from "customer"
order by "customer_id" desc
limit 10;

--17: nombre y apellidos actores película 'Egg Igby'--
select 
     concat(a."first_name",' ',a."last_name") as "nombre_actor",
     f."title" as "pelicula" 
from "actor" a
inner join "film_actor" fa ON fa."actor_id" = a."actor_id"
inner join "film" f       ON f."film_id" = fa."film_id"
where f."title" ilike 'Egg Igby';

--18: seleccionar los nombre de las películas únicos--
select distinct"title"
from "film"
order by "title";

--19: título de comedias > 180 min--
select 
     f."title", f."length",
     ca."name" as "categoría"
from "film" f
inner join "film_category" fac ON fac."film_id" = f."film_id"
inner join "category" ca       ON ca."category_id" = fac."category_id"
where f."length" > 180
and ca."name" = 'Comedy';

--20:categorías de películas con promedio superior a 110min--
select 
     ca."name" as "categoría",
     round(avg(f."length"), 0) as "duración_media"
from "film" f
inner join "film_category" fac ON fac."film_id" = f."film_id"
inner join "category" ca       ON ca."category_id" = fac."category_id"
group by ca."name"
having avg(f."length") > 110;

--21:media duración alquiler películas--
select round(avg("return_date"::date - "rental_date"::date),0) as "media_duración_días"
from "rental";

--22: columna con nombre y apellidos de los actores--
select concat("first_name",' ',"last_name") as "nombre_actor" 
from "actor";

--23: nº alquileres x día/ ordenado por cantidad des--
select "rental_date"::date, count(*) as "cantidad_alquiler"
from "rental"
group by "rental_date"::date
order by "cantidad_alquiler" desc;

--24: peliculas con duración superior al promedio--
select "title", "length"
from "film"
where "length" > (
     select avg("length")
     from "film");

--25: nº alquileres registrados x mes--
select 
  to_char("rental_date", 'YYYY-MM') as mes,
  count(*) as "cantidad_alquiler"
from "rental"
group by to_char("rental_date", 'YYYY-MM');

--26: promedio, desviación estandar y varianza del total pagado--
select 
    round(avg ("amount"),0) as "promedio_ingresos",
    round(stddev ("amount"),0) as "desviación_estandar_ingresos",
    round(variance ("amount"),0) as "varianza_ingresos"
from "payment";

--27: películas que se alquilan por encima del precio medio--
select count(*)
from (
    select f."film_id"
    from "film" f
    inner join "inventory" i ON i."film_id" = f."film_id"
    inner join "rental" r    ON r."inventory_id" = i."inventory_id"
    inner join "payment" p   ON p."rental_id" = r."rental_id"
    group by f."film_id"
    having avg(p."amount") > (
        select avg("amount")
        from "payment"
    )
) t;
   
--28: mostrar Id de actores > 40 peliculas--
select "actor_id", count("film_id") as total_peliculas
from "film_actor"
group by "actor_id"
having count("film_id") > 40
order by total_peliculas desc;


--29: obtener todas las peliculas y mostrar cantidad disponible del inventario--
select 
     f."title",
     round(count (i."film_id"),0) as "películas_disponibles"
from "film" f
join "inventory" i       ON i."film_id" = f."film_id"
group by f."title";

--30: actores y nº peliculas que ha actuado--
select 
     concat(a."first_name",' ',a."last_name") as "nombre_actor",
     count(f."title") as "nº_películas"
from "actor" a
inner join "film_actor" fa ON fa."actor_id" = a."actor_id"
inner join "film" f       ON f."film_id" = fa."film_id"
group by "nombre_actor";

--31: películas y sus actores--
select 
     f."title",
     string_agg(concat(a."first_name",' ',a."last_name"),
     ', '
     order by a."last_name") as "actores"
from "actor" a
right join "film_actor" fa ON fa."actor_id" = a."actor_id"
right join "film" f       ON f."film_id" = fa."film_id"
group by f."title";

--32: Actores y sus películas--
select 
     concat(a."first_name",' ',a."last_name") as "actor",
     string_agg(f."title",
     ', '
     order by f."title") as "películas"
from "actor" a
left join "film_actor" fa ON fa."actor_id" = a."actor_id"
left join "film" f       ON f."film_id" = fa."film_id"
group by "actor";

--33: Todas las peliculas que tenemos y los registros de alquiler--
/* He sacado el nº de peliculas que tenemos y el nº de títulos de peliculas que tenemos, 
 * ya que tenemos varias películas de cada título */
select count(distinct r."rental_id") as "nº_alquileres", 
       count(distinct i."inventory_id") as "nº_peliculas", 
       count(distinct f."film_id") as "nº_títulos_diferentess"
from "film" f
left join "inventory" i on i."film_id" = f."film_id"
left join "rental" r on r."inventory_id" = i."inventory_id";

--34: top 5 clientes que más dinero se han gastado--
select concat(c."first_name",' ',c."last_name") as "cliente", 
       sum(p."amount") as "gasto"
from "payment" p
left join "rental" r on r."rental_id" = p."rental_id"
left join "customer" c on c."customer_id" = r."customer_id"
group by "cliente"
order by "gasto" desc
limit 5;

--35: Todos los actores con nombre Johnny--
select concat("first_name",' ',"last_name") as "actor"
from "actor"
where "first_name" = 'JOHNNY';

--36: Renombra las columnas como Nombre y Apellido --
select "first_name" as "Nombre",
       "last_name" as "Apellido"
from "actor";

--37: encuentra el ID de actor más bajo y el más alto--
select min("actor_id") as "id_más_bajo",
       max("actor_id") as "id_más_alto"
from "actor";

--38: nº actores en la tabla actor--
select count(distinct "actor_id")
from "actor";

--39: selecciona todos los actores y ordénalos por apellido ascendente--
select concat("first_name",' ',"last_name")
from "actor"
order by "last_name" asc;

--40: primeras 5 películas de la tabla film--
select "film_id", "title"
from "film"
limit 5;

--41: agrupa los actores por su nombre y cuenta los que se repiten, el 1º el más repetido--
select "first_name",
       count("first_name") 
from "actor"
group by "first_name"
order by count("first_name") desc;

--42: todos los alquileres y los clientes que los realizaron--
select r."rental_id",
       concat(c."first_name",' ',c."last_name") as "cliente"
from "rental" r
left join "customer" c on c."customer_id" = r."customer_id";

--43: todos los clientes y sus alquileres, incluyendo los que no tienen--
select concat(c."first_name",' ',c."last_name") as "cliente",
       count(r."rental_id") as "nº_alquileres"
from "customer" c 
left join "rental" r on r."customer_id" = c."customer_id"
group by "cliente"
order by "nº_alquileres" asc;

--44: CROSS JOIN de film + category--
select*
from "film"
cross join "category";
/* esta consulta no aporta valor, ya que, cada película tiene solo una categoría */

--45: actores que han participado en la categoría action--
select concat(a."first_name",' ',a."last_name") as "actor",
       string_agg(distinct f."title", ', ' order by f."title") as "películas",
       c."name"
from "actor" a
left join "film_actor" fa on fa."actor_id" = a."actor_id"
left join "film" f on f."film_id" = fa."film_id"
left join "film_category" fc on fc."film_id" = f."film_id"
left join "category" c on c."category_id" = fc."category_id"
where c."name" = 'Action'
group by a."actor_id", a."first_name", a."last_name", c."name";

--46: actores que no han participado en películas--
--Realizando la siguiente consulta, y ordenando de menor a mayor el nº de películas, observamos que no existen actores sin películas--

--47: nombre de actores y nº de películas en las que ha participado--
select fa."actor_id",
       concat(a."first_name",' ',a."last_name") as "actor",
       count (distinct fa."film_id") as "nº_películas"
from "actor" a
left join "film_actor" fa on fa."actor_id" = a."actor_id"
group by a."first_name", a."last_name", fa."actor_id"
order by "nº_películas";

--48: crea una vista llamada "actor_num_peliculas" con los resultados del enunciado 47--
create view "actor_num_peliculas" as
select fa."actor_id",
       concat(a."first_name",' ',a."last_name") as "actor",
       count (distinct fa."film_id") as "nº_películas"
from "actor" a
left join "film_actor" fa on fa."actor_id" = a."actor_id"
group by a."first_name", a."last_name", fa."actor_id"
order by "nº_películas";

--comprobación de la creación del enunciado 48--
select*
from "actor_num_peliculas";

--49: calcula el nº total de alquileres x cada cliente--
--Es lo mismo que la consulta 43 ¿no?--

--50: cualcula la duración total de las peliculas de action--
select c."name",
       sum(f."length")
from "film" f
left join "film_category" fc on fc."film_id" = f."film_id"
left join "category" c on c."category_id" = fc."category_id"
where c."name" = 'Action'
group by c."name";

--51: crear una tabla temporal llamada "clientes_renta_temporal" total alquileres por cliente--
create temporary table clientes_rentas_temporal as 
select concat(c."first_name",' ',c."last_name") as "cliente",
       count(r."rental_id") as "nº_alquileres"
from "customer" c 
left join "rental" r on r."customer_id" = c."customer_id"
group by "cliente" ;
--Comprobación tabla temporal--
select "cliente","nº_alquileres"
from "clientes_rentas_temporal";

--52: crea una tabla temporal llamada "peliculas_alquiladas" con las peliculas alquiladas min 10 veces--
create temporary table peliculas_alquiladas as
select f."title" as "película",
       count(r."rental_id") as "nº_alquileres"
from "rental" r
left join "inventory" i on i."inventory_id" = r."inventory_id"
left join "film" f on f."film_id" = i."film_id"
group by f."title"
having count(r."rental_id") > 10;
--Comprobación tabla temporal--
select "title","nº_alquileres"
from "peliculas_alquiladas";

--53: películas alquiladas y no devueltas por Tammy Sanders, ordenado por título abc--
--uso la estructura de datos temporales para mejorar los filtros de la consulta--

with tammy as (
   select c."customer_id",
          concat(c."first_name",' ',c."last_name") as "cliente"
   from "customer" c
   where c."first_name" = 'TAMMY'
     and c."last_name"  = 'SANDERS'
),
peliculas_de_tammy as (
   select t."cliente",
          r."inventory_id"
   from "rental" r
   join tammy t on t."customer_id" = r."customer_id"
   where r."return_date" is null
)
select p."cliente",
       p."inventory_id",
       f."title"
from peliculas_de_tammy p
join "inventory" i on i."inventory_id" = p."inventory_id"
join "film" f on f."film_id" = i."film_id"
order by f."title" asc;


--54: actores que han participado en al menos una pelicula Sci-fi y ordenar por apellido abc--
with peliculas_SF as (
    select 
     f."title", f."film_id",
     ca."name" as "categoría"
    from "film" f
    inner join "film_category" fac ON fac."film_id" = f."film_id"
    inner join "category" ca       ON ca."category_id" = fac."category_id"
    where ca."name" = 'Sci-Fi'
)
select concat(a."first_name",' ',a."last_name") as "actor",
       count(ps."title") as "nº_peliculas_Sci-Fi"
from peliculas_SF ps
inner join "film_actor" fa on fa."film_id" = ps."film_id"
inner join "actor" a on a."actor_id" = fa."actor_id"
group by a."first_name", a."last_name"
order by a."last_name" asc;

/*55: Nombre y apellido de actores que han actuado en peliculas
 * que se alquilaron despues de que la pelicula Spartacus Cheaper
 * se alquila por primera vez. Ordenado por apellido abc*/ 
select min("rental_date"::date),
       f."title"
from "rental" r
left join "inventory" i on i."inventory_id" = r."inventory_id"
left join "film" f on f."film_id" = i."film_id"
where f."title" = 'SPARTACUS CHEAPER'
group by f."title";

--obteniendo que la fecha es 2005-07-08, filtramos--
with peliculas_post_Spartacus as (
    select "inventory_id"
    from "rental"
    where "rental_date" > date '2005-07-08'
)
select concat(a."first_name",' ',a."last_name") as "actor",
       count(distinct pp."inventory_id")
from peliculas_post_Spartacus pp
inner join "inventory" i on i."inventory_id" = pp."inventory_id"
inner join "film" f on f."film_id" = i."film_id"
inner join "film_actor" fa on fa."film_id" = f."film_id"
inner join "actor" a on a."actor_id" = fa."actor_id"
group by a."first_name", a."last_name"
order by a."last_name" asc;

--56: Nombre y apellido de actores que no han actuado en peliculas Music--
with peliculas_Music as (
    select 
     f."title", f."film_id",
     ca."name" as "categoría"
    from "film" f
    inner join "film_category" fac ON fac."film_id" = f."film_id"
    inner join "category" ca       ON ca."category_id" = fac."category_id"
    where ca."name" = 'Music'
)
select concat(a."first_name",' ',a."last_name") as "actor",
       count(pm."title") as "nº_peliculas_Music"
from "actor" a
left join "film_actor" fa on fa."actor_id" = a."actor_id"
left join peliculas_Music pm on pm."film_id" = fa."film_id"
group by a."first_name", a."last_name"
having  count(distinct pm."film_id") = 0;

--57: título de peliculas alquiladas por más de 8 días--
with peliculas_8dias as (
select "rental_id", "inventory_id",
       sum("return_date"::date - "rental_date"::date) as "duración_días"
from "rental"
group by "rental_id"
having sum("return_date"::date - "rental_date"::date) > 8
)
select p8."rental_id",
       p8."duración_días",
       f."title"
from peliculas_8dias p8
inner join "inventory" i on i."inventory_id" = p8."inventory_id"
inner join "film" f on f."film_id" = i."film_id";

--58: películas categoría Animation--
select f."title",
       c."name"
from "film" f
left join "film_category" fc on fc."film_id" = f."film_id"
left join "category" c on c."category_id" = fc."category_id"
where c."name" = 'Animation';

--59: películas con misma duración que Dancing Fever, ordenado abc--
select "title", "length"
from "film"
where "length" = (
      select "length"
      from "film"
      where "title" = 'DANCING FEVER')
order by "title" asc;

--60: Nombre de los clientes que han alquilado al menos 7 películas distintas, ordenado por apellido abc--
select  concat(c."first_name",' ',c."last_name") as "cliente",
        count (distinct i."film_id") as "nº_peliculas_diferentes"
from "rental" r
inner join "customer" c on c."customer_id" = r."customer_id"
inner join "inventory" i on i."inventory_id" = r."inventory_id"
group by c."first_name",c."last_name"
having count (distinct i."film_id") >= 7
order by c."last_name" asc;

--61: nº total de alquileres por categoría--
select c."name",
       count (r."rental_id")
from "rental" r
left join "inventory" i on i."inventory_id" = r."inventory_id"
left join "film" f on f."film_id" = i."film_id"
left join "film_category" fc on fc."film_id" = f."film_id"
left join "category" c on c."category_id" = fc."category_id"
group by c."name"
order by count (r."rental_id") desc;

--62: nº películas estrenadas en 2006--
select count(distinct "title")
from "film"
where "release_year" = 2006;

--63: todas las combinaciones posibles de trabajadores con las tiendas--
select sta."staff_id",
       concat(sta."first_name",' ',sta."last_name") as "nombre_empleado",
       sto."store_id",
       sto."address_id"
from "staff" sta
cross join "store" sto;

--64: cantidad total películas alquiladas x cliente--
select c."customer_id",
       concat(c."first_name",' ',c."last_name") as "cliente",
       count (rental_id)
from "rental" r
inner join "customer" c on c."customer_id" = r."customer_id"
group by c."customer_id";