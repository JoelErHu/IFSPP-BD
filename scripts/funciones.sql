
set search_path to "mdJ_streaming2";

--Funcion para poder ver cuantas reproducciones validas tiene una cancion
create or replace function fn_reproducciones_cancion(fn_id_cancion int)
returns int
language plpgsql
stable
as $$
begin
	return (
	select count(*)
	from reproducida r
		join cancion c
		on r.id_cancion = c.id_cancion
	where r.id_cancion = fn_id_cancion
		and r.tiempo_reproduccion >= c.duracion * 0.3
	);
end;
$$;

--Funcion para ver cuantas reproducciones validas que tiene un artista
create or replace function fn_reproducciones_artista (fn_id_artista int)
returns int
language plpgsql
stable
as $$
begin
	return(
	select count(*)
	from compone com
		join cancion c     
			on c.id_cancion = com.id_cancion
		join reproducida r 
			on r.id_cancion = c.id_cancion
	where com.id_artista = fn_id_artista
		and r.tiempo_reproduccion >= c.duracion * 0.3
	);
end;
$$;




