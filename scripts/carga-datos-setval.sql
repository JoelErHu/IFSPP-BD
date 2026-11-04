
set search_path to "mdJ_streaming2";

--Los setval para sincronizar el generador interno de secuencias con los ids cargados, para futuros insert.

select setval(pg_get_serial_sequence('categoria', 'id_categoria'),
              (select max(id_categoria) from categoria), true);

select setval(pg_get_serial_sequence('usuario', 'id_usuario'),
              (select max(id_usuario) from usuario), true);

select setval(pg_get_serial_sequence('artista', 'id_artista'),
              (select max(id_artista) from artista), true);

select setval(pg_get_serial_sequence('album', 'id_album'),
              (select max(id_album) from album), true);

select setval(pg_get_serial_sequence('cancion', 'id_cancion'),
              (select max(id_cancion) from cancion), true);

select setval(pg_get_serial_sequence('sesion', 'id_sesion'),
              (select max(id_sesion) from sesion), true);

