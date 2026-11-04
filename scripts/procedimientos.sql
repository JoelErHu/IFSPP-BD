
set search_path to "mdJ_streaming2";


--Procedimiento para registrar la reproduccion de un usuario en una cancion
create or replace procedure pro_registrar_reproduccion(pro_id_usuario int, pro_id_cancion int, pro_tiempo_reproduccion int, pro_dispositivo varchar)
language plpgsql
set search_path = "mdJ_streaming2"
as $$
declare
    v_ahora     timestamp default clock_timestamp();
    v_id_sesion int;
    v_duracion  int;
begin
    --Verifica que los parametros se cumplan
    if pro_id_usuario is null or pro_id_cancion is null
       or pro_tiempo_reproduccion is null or pro_dispositivo is null then
        rollback;
        raise exception 'Todos los parámetros son obligatorios';
    end if;

    --Verifica que el usuario exista
    if not exists (select 1 from usuario where id_usuario = pro_id_usuario) then
        rollback;
        raise exception 'El usuario % no existe', pro_id_usuario;
    end if;

    --Verifica que la cancion exista
    select duracion into v_duracion
    from cancion
    where id_cancion = pro_id_cancion;

    if not found then
        rollback;
        raise exception 'La canción % no existe', pro_id_cancion;
    end if;

    --Verifica que la reproduccion concuerde con la duracion de la cancion
    if pro_tiempo_reproduccion < 4 or pro_tiempo_reproduccion > v_duracion then
        rollback;
        raise exception 'Tiempo inválido: % s (la canción % dura % s, mínimo 4 s)',
            pro_tiempo_reproduccion, pro_id_cancion, v_duracion;
    end if;

    --Cierra las sesiones del usuario con mas de 30 minutos sin actividad
    update sesion s
       set fecha_final = coalesce(u.ultima_actividad, s.fecha_inicio)
      from (select s2.id_sesion,
                   max(r.fecha_reproduccion + r.hora_reproduccion
                       + r.tiempo_reproduccion * interval '1 second') as ultima_actividad
              from sesion s2
                   left join reproducida r on r.id_sesion = s2.id_sesion
             where s2.id_usuario = pro_id_usuario
               and s2.fecha_final is null
             group by s2.id_sesion) u
     where s.id_sesion = u.id_sesion
       and coalesce(u.ultima_actividad, s.fecha_inicio) < v_ahora - interval '30 minutes';

    --Busca si hay una sesion abierta en el dispositivo
    select id_sesion into v_id_sesion
    from sesion
    where id_usuario = pro_id_usuario
      and dispositivo = pro_dispositivo
      and fecha_final is null
    order by fecha_inicio desc
    limit 1;

    --Abre una sesion nueva si no hay ninguna activa
    if v_id_sesion is null then
        insert into sesion (fecha_inicio, dispositivo, id_usuario)
        values (v_ahora, pro_dispositivo, pro_id_usuario)
        returning id_sesion into v_id_sesion;
    end if;

    --Registra la reproduccion
 	insert into reproducida (id_sesion, id_cancion,
                             hora_reproduccion, fecha_reproduccion, tiempo_reproduccion)
    values (v_id_sesion, pro_id_cancion,
            v_ahora, v_ahora, pro_tiempo_reproduccion);

    commit;
    raise notice 'Reproducción registrada en la sesión %', v_id_sesion;
end;
$$;
