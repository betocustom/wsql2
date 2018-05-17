
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[splibrem_columna]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[splibrem_columna]
GO
create procedure [dbo].[splibrem_columna] (
		@sp_mes				int,
		@sp_ano				int,
		@sp_empresa			int,
		@sp_planta			int,
		@sp_proceso			char(4),
		@sp_cod_libro		int,
		@sp_nro_trabajador	int,
		@sp_cod_columna		int,
		@sp_empresa_trab	int,
		@sp_planta_trab		int,
		@sp_forzar_lq		int,
		@es_centra_absoluta	char(1),
		@nvalortotal		decimal(14,4) output,
		@svalortotal		varchar(100) output )
as declare	@sp_cod_operacion		char(1),
			@sp_cod_origen			char(1),
			@sp_cod_dato			varchar(40),
			@sp_orden_operacioncol	int,
			@sp_n_cod_dato			int,
			@nvalorlocal			decimal(14,4),
			@squery					nvarchar (4000),
			@sparam					nvarchar(255),
			@nmes_compara			int,
			@nano_compara			int,
			@stablapersonal			varchar(40),
			@stablapersodin			varchar(40),
			@scondicionhistorico	varchar(200),
			@scondicionhistperdi	varchar(200),
			@sintabla				int, 
			@sp_cod_dato_decof		varchar(18),
			@sp_codigo_asis			varchar(4),
			@nCantidadReg			int,
			@sCodTipoDinamico		char(1),
			@sp_flg_transaccion		char(1)
select	@nvalortotal = 0
select	@nano_compara = ano_proc_cont_proc,  
		@nmes_compara = cod_mes_proceso 
from	control_procesos 
where	cod_empresa			= @sp_empresa 
and		cod_planta			= @sp_planta  
and		fec_proces_vigente	= 'AB'

if @nano_compara = @sp_ano and @nmes_compara = @sp_mes
		begin
		select	@stablapersonal = 'personal'
		select  @stablapersodin = 'personal_dinamico' 
		select	@scondicionhistorico = ' '
		select  @scondicionhistperdi = ' '
		end
else
		begin
		select	@stablapersonal = 'historico_personal'
		select  @stablapersodin = 'hist_perso_dina' 
		select	@scondicionhistorico = ' and historico_personal.ano_periodo = ' + convert(varchar(4), @sp_ano) + ' and historico_personal.mes_periodo = ' + convert(varchar(4),@sp_mes)
		select	@scondicionhistperdi = ' and hist_perso_dina.ano_periodo = ' + convert(varchar(4), @sp_ano) + ' and hist_perso_dina.mes_periodo = ' + convert(varchar(4),@sp_mes)
		end
declare cur_lib_entradas cursor for
select	cod_operacion, 
		cod_origen, 
		cod_dato, 
		orden_operacion,
		flg_transaccion
from	libro_entradas
where	cod_empresa		= @sp_empresa   
and		cod_planta		= @sp_planta
and		cod_libro		= @sp_cod_libro 
and		cod_columna		= @sp_cod_columna
group by cod_operacion, cod_origen, cod_dato, orden_operacion, flg_transaccion
order by orden_operacion
for read only
open cur_lib_entradas
fetch cur_lib_entradas into @sp_cod_operacion, @sp_cod_origen, @sp_cod_dato, @sp_orden_operacioncol, @sp_flg_transaccion
while @@fetch_status = 0
	begin
    select @nvalorlocal = 0
    select @svalortotal = ''
    if @sp_cod_origen = 'H'
		begin
		print 'Entro en H'
		if @sp_flg_transaccion = 'T'
			begin
			select	@sp_n_cod_dato = cast( @sp_cod_dato as int)
			select	@nvalorlocal		= sum(valor_transaccion)
			from	liquidacio_haberes
			where	cod_empresa			= @sp_empresa_trab      
			and		cod_planta			= @sp_planta_trab
			and		ano_periodo			= @sp_ano            
			and		mes_periodo			= @sp_mes            
			and		cod_tipo_proceso	= @sp_proceso        
			and		nro_trabajador		= @sp_nro_trabajador 
			and		cod_haber			= @sp_n_cod_dato
			end
		else
			begin
			--print 'aqui'
			select	@sp_n_cod_dato = cast( @sp_cod_dato as int)
			select	@nvalorlocal		= sum(valor_transac_peso)
			from	liquidacio_haberes
			where	cod_empresa			= @sp_empresa_trab        
			and		cod_planta			= @sp_planta_trab
			and		ano_periodo			= @sp_ano            
			and		mes_periodo			= @sp_mes            
			and		cod_tipo_proceso	= @sp_proceso        
			and		nro_trabajador		= @sp_nro_trabajador 
			and		cod_haber			= @sp_n_cod_dato
			--print 'sum(valor_transac_peso) = ' + cast( @nvalorlocal as varchar(20))
			end
		end
    else if @sp_cod_origen = 'D'
		begin
		print 'Entro en D'
		if @sp_flg_transaccion = 'T'
			begin
			select	@sp_n_cod_dato		= cast( @sp_cod_dato as int)
			select	@nvalorlocal		= sum(valor_transaccion)
			from	liquida_descuentos
			where	cod_empresa			= @sp_empresa_trab        
			and		cod_planta			= @sp_planta_trab
			and		ano_periodo			= @sp_ano            
			and		mes_periodo			= @sp_mes            
			and		cod_tipo_proceso	= @sp_proceso        
			and		nro_trabajador		= @sp_nro_trabajador 
			and		cod_descuento		= @sp_n_cod_dato
			end
		else
			begin
			select	@sp_n_cod_dato		= cast( @sp_cod_dato as int)
			select	@nvalorlocal		= sum(valor_transac_peso)
			from	liquida_descuentos
			where	cod_empresa			= @sp_empresa_trab        
			and		cod_planta			= @sp_planta_trab
			and		ano_periodo			= @sp_ano            
			and		mes_periodo			= @sp_mes            
			and		cod_tipo_proceso	= @sp_proceso        
			and		nro_trabajador		= @sp_nro_trabajador 
			and		cod_descuento		= @sp_n_cod_dato
			end
		end 
	else if @sp_cod_origen = 'I'
		begin
		print 'entro en I'
		select	@sCodTipoDinamico	= tipo_dato 
		from	columna_dinamica 
		where	cod_empresa			= @sp_empresa_trab
		and		nombre_interno		= @sp_cod_dato
		if @sCodTipoDinamico = 'A'
			begin
			select	@squery = 'select @svalortotal = convert(varchar(100), valor_columna ) '
			select	@squery = @squery + ' from	' + @stablapersodin
			select	@squery = @squery + ' where ' + @stablapersodin + '.cod_empresa		= ' + convert( varchar(8), @sp_empresa_trab )
			select	@squery = @squery + ' and   ' + @stablapersodin + '.nro_trabajador	= ' + convert( varchar(10), @sp_nro_trabajador )
			select	@squery = @squery + ' and   ' + @stablapersodin + '.nombre_interno	= ''' + convert( varchar(16), @sp_cod_dato ) + ''' '  
			select	@squery = @squery + @scondicionhistperdi
			select	@sparam = ' @svalortotal varchar(100) output '
			execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
			end
		else if @sCodTipoDinamico = 'N'
			begin
			select	@squery = 'select @nvalorlocal = valor_numerico '
			select	@squery = @squery + ' from	' + @stablapersodin
			select	@squery = @squery + ' where ' + @stablapersodin + '.cod_empresa		= ' + convert( varchar(8), @sp_empresa_trab )
			select	@squery = @squery + ' and   ' + @stablapersodin + '.nro_trabajador	= ' + convert( varchar(10), @sp_nro_trabajador )
			select	@squery = @squery + ' and   ' + @stablapersodin + '.nombre_interno	= ''' + convert( varchar(16), @sp_cod_dato ) + ''' '  
			select	@squery = @squery + @scondicionhistperdi
			--print @squery
			select	@sparam = '@nvalorlocal decimal(13,4) output '
			execute sp_executesql @squery , @sparam,  @nvalorlocal = @nvalorlocal output
			end
		else if @sCodTipoDinamico = 'C'
			begin
			select	@squery = 'select @svalortotal = convert(varchar(100), codigos_genericos.descripcion ) '
			select	@squery = @squery + ' from		columna_dinamica, '
			select	@squery = @squery + '			codigos_genericos, '
			select	@squery = @squery +  			@stablapersodin
			select	@squery = @squery + ' where		columna_dinamica.cod_empresa		= ' + convert( varchar(8), @sp_empresa_trab )
			select	@squery = @squery + ' and		columna_dinamica.nombre_interno		= ''' + convert( varchar(16), @sp_cod_dato ) + ''' '
			select	@squery = @squery + ' and		codigos_genericos.tipo_codigo		= columna_dinamica.tipo_codigo '
			select	@squery = @squery + ' and		' + @stablapersodin + '.cod_empresa		= columna_dinamica.cod_empresa '
			select	@squery = @squery + ' and		' + @stablapersodin + '.nombre_interno	= columna_dinamica.nombre_interno '
			select	@squery = @squery + ' and		' + @stablapersodin + '.valor_columna		= codigos_genericos.codigo '
			select	@squery = @squery + ' and		' + @stablapersodin + '.nro_trabajador	= ' + convert( varchar(10), @sp_nro_trabajador ) + ' '
			select	@squery = @squery + @scondicionhistperdi
			select	@sparam = ' @svalortotal varchar(100) output '
			execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
			end
		else if @sCodTipoDinamico = 'F'
			begin
			select	@squery = 'select @svalortotal = convert(varchar(10), valor_fecha, 103) '
			select	@squery = @squery + ' from	' + @stablapersodin
			select	@squery = @squery + ' where ' + @stablapersodin + '.cod_empresa		= ' + convert( varchar(8), @sp_empresa_trab )
			select	@squery = @squery + ' and   ' + @stablapersodin + '.nro_trabajador	= ' + convert( varchar(10), @sp_nro_trabajador )
			select	@squery = @squery + ' and   ' + @stablapersodin + '.nombre_interno	= ''' + convert( varchar(16), @sp_cod_dato ) + ''' '  
			select	@squery = @squery + @scondicionhistperdi
			select	@sparam = ' @svalortotal varchar(100) output '
			execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
			end
		end
    else if @sp_cod_origen = 'P'
		begin
		print 'entro a P'
        select	@nvalorlocal	= 0
        select	@svalortotal	= ''
        select	@sintabla		= 0
        if @sp_cod_dato = 'tipo_contrato' 
			begin
            select	@sintabla	= 1
            select	@sp_cod_dato_decof = @sp_cod_dato
            select	@sp_cod_dato	= 'codigo_tipo_contra'
			end
        if upper(substring(@sp_cod_dato,1,4)) = 'HRS_' 
			begin
            select	@sp_codigo_asis = substring(@sp_cod_dato,5,4)
            if exists(	select 1 
			from	movimient_asistenc
			where	cod_empresa    = @sp_empresa_trab            
			and		cod_planta     = @sp_planta_trab
			and		nro_trabajador = @sp_nro_trabajador     
			and		cod_asistencia = @sp_codigo_asis )
			select	@svalortotal = CONVERT(varchar(12), SUM(cantidad))
			from	movimient_asistenc 
			where	cod_empresa    = @sp_empresa_trab            
			and		cod_planta     = @sp_planta_trab
			and		nro_trabajador = @sp_nro_trabajador     
			and		cod_asistencia = @sp_codigo_asis
            else
			select	@svalortotal = CONVERT(varchar(12), SUM(cantidad))
			from	histor_asistencias 
			where	cod_empresa    = @sp_empresa_trab            
			and		cod_planta     = @sp_planta_trab
			and		nro_trabajador = @sp_nro_trabajador     
			and		anos_consev_histor = @sp_ano            
			and		mes_cons_info_hist = @sp_mes            
			and		cod_tipo_proceso = @sp_proceso          
			and		cod_asistencia = @sp_codigo_asis   
			end
		else
			begin
				if @sp_cod_dato = 'sucursal.sucursal' 
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ', sucursal '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_sucursal		= sucursal.cod_sucursal '
					select  @squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= sucursal.cod_empresa '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= sucursal.cod_planta '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico	    
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'linea_produccion.descripcion'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ', linea_produccion '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_linea_prod		= linea_produccion.cod_linea_prod '
					select	@squery = @squery + @scondicionhistorico	    
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'tipo_contabilizaci'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ' '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador )
					select	@squery = @squery + ' '
					select	@squery = @squery + @scondicionhistorico	    
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'multiples_concepto.descripcion'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ', multiples_concepto '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.tipo_contabilizaci	= multiples_concepto.grupo_contable '
					select  @squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= multiples_concepto.cod_empresa '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= multiples_concepto.cod_planta '
					select	@squery = @squery + @scondicionhistorico	    
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'lugar_pago.lugar_pago'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ', lugar_pago '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_lugar_pago		= lugar_pago.cod_lugar_pago '
					select  @squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= lugar_pago.cod_empresa '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= lugar_pago.cod_planta '
					select	@squery = @squery + ' and   lugar_pago.cod_vigente = ''S'' '
					select	@squery = @squery + @scondicionhistorico	    
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'unidad_administrat.unidad_administrat'
					begin               
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ',unidad_administrat '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select  @squery = @squery + ' and   ' + @stablapersonal + '.cod_unidad_adminis	= unidad_administrat.cod_unidad_adminis '
					select  @squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= unidad_administrat.cod_empresa '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico	    
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'tipo_finiquito.tipo_contrato'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ', tipo_finiquito '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(10), @sp_planta_trab  )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_retiro			= tipo_finiquito.codigo_tipo_contra '
					select	@squery = @squery + ' and	' + @stablapersonal + '.cod_empresa			= tipo_finiquito.cod_empresa '
					select	@squery = @squery + @scondicionhistorico	    
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'cod_retiro' or @sp_cod_dato = 'tipo_finiquito.codigo_tipo_contra'
					begin	
					select  @sp_cod_dato = 'cod_retiro'										
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ' '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'fec_antiguedad' or @sp_cod_dato = 'fec_ini_contrato' or @sp_cod_dato = 'fec_fin_contr_vige' or @sp_cod_dato = 'fec_nacimiento'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(10),' + @sp_cod_dato + ', 103) from '+ @stablapersonal + ', afp, isapre, jornada_trabajo, centro_costo, cargo_trabajador '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_afp				= afp.cod_afp '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_isapre			= isapre.cod_isapre '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= jornada_trabajo.cod_empresa ' 
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= jornada_trabajo.cod_planta ' 
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_jornada			= jornada_trabajo.cod_jornada '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_centro_costo	= centro_costo.cod_centro_costo '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= centro_costo.cod_empresa '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador)
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_cargo			= cargo_trabajador.cod_cargo '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= cargo_trabajador.cod_empresa '
					select	@squery = @squery + @scondicionhistorico	    
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'sindicato.sindicato'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ',sindicato '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select  @squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= sindicato.cod_empresa '
					select  @squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= sindicato.cod_planta '
					select  @squery = @squery + ' and   ' + @stablapersonal + '.cod_sindicato		= sindicato.cod_sindicato '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'convenio.nombre_convenio'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ',convenio '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select  @squery = @squery + ' and   ' + @stablapersonal + '.convenio			= convenio.convenio '
					select  @squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= convenio.cod_empresa '
					select	@squery = @squery + @scondicionhistorico
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'area_perten.area_perten'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ',area_perten '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select  @squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= area_perten.cod_empresa '
					select  @squery = @squery + ' and   ' + @stablapersonal + '.cod_area_perten		= area_perten.cod_area_perten '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'lugar_prestacion.representan_legal'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ',lugar_prestacion '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select  @squery = @squery + ' and   ' + @stablapersonal + '.cod_lugprestacion	= lugar_prestacion.cod_lugprestacion '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'cod_centro_costo'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ' '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				--nuevo
				else if @sp_cod_dato = 'comuna.comuna'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ', comuna '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select	@squery = @squery + ' and	' + @stablapersonal + '.cod_comuna			= comuna.cod_comuna ' 
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'afp.pje_cotiz_previsio'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ', afp '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select	@squery = @squery + ' and	' + @stablapersonal + '.cod_afp				= afp.cod_afp ' 
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico
					select	@sparam = ' @svalortotal varchar(100) output '
					--print	@squery
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'empresa.rut_empresa'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') + ''-'' + dv_rut_empresa from '+ @stablapersonal +  ', empresa '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select	@squery = @squery + ' and	' + @stablapersonal + '.cod_empresa			= empresa.cod_empresa ' 
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				--fin nuevo
				else if @sp_cod_dato = 'banco.banco'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ', banco '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select	@squery = @squery + ' and	' + @stablapersonal + '.cod_banco			= banco.cod_banco ' 
					select	@squery = @squery + ' and	banco.cod_vigente = ''S'' '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'medio_pago.medio_pago'
					begin
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ', medio_pago '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select	@squery = @squery + ' and	' + @stablapersonal + '.cod_empresa			= medio_pago.cod_empresa '
					select	@squery = @squery + ' and	' + @stablapersonal + '.cod_medio_pago		= medio_pago.cod_medio_pago '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'rut_trabajador'
					begin											
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') + ''-'' + dv_rut_trabajador from '+ @stablapersonal +  ' '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else if @sp_cod_dato = 'direccion'
					begin											
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal +  ' '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador) + ' '
					select	@squery = @squery + @scondicionhistorico
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
				else
					begin
					print 'Entro a generico'
					select	@squery = 'select @svalortotal = ' + 'convert(varchar(100),' + @sp_cod_dato + ') from '+ @stablapersonal + ', afp, isapre, jornada_trabajo, centro_costo, cargo_trabajador, empresa, planta '
					select	@squery = @squery + ' where ' + @stablapersonal + '.cod_empresa			= ' + convert( varchar(8), @sp_empresa_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador  )
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= empresa.cod_empresa '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= planta.cod_empresa '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= planta.cod_planta '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_afp				= afp.cod_afp '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_isapre			= isapre.cod_isapre '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= jornada_trabajo.cod_empresa ' 
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_planta			= jornada_trabajo.cod_planta ' 
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_jornada			= jornada_trabajo.cod_jornada '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_centro_costo	= centro_costo.cod_centro_costo '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= centro_costo.cod_empresa '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.nro_trabajador		= ' + convert( varchar(10), @sp_nro_trabajador)
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_cargo			= cargo_trabajador.cod_cargo '
					select	@squery = @squery + ' and   ' + @stablapersonal + '.cod_empresa			= cargo_trabajador.cod_empresa '
					select	@squery = @squery + @scondicionhistorico	    
					select	@sparam = ' @svalortotal varchar(100) output '
					execute sp_executesql @squery, @sparam, @svalortotal = @svalortotal output
					end
            if @sintabla = 1
				begin
                if @sp_cod_dato_decof = 'tipo_contrato' 
					begin
                    if @svalortotal = 'P'
						select	@svalortotal = 'Permanente'
                    else if @svalortotal = 'F'
						select	@svalortotal = 'Plazo Fijo'
                    else if @svalortotal = 'O'
						select	@svalortotal = 'Obra/Faena'
                    else
						select	@svalortotal = ''
					end
				end 
			end
		end
    else
		begin
        if @sp_cod_origen <> 'P' 
			begin
			if @sp_cod_origen = 'L' and @sp_forzar_lq = 1
				begin
				select	@squery = 'select @nvalorlocal = ' + @sp_cod_dato + ' from historico_liquidac '
				select	@squery = @squery + 'where cod_empresa		= ' + convert( char(8), @sp_empresa_trab )
				select	@squery = @squery + 'and cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
				select	@squery = @squery + 'and ano_periodo		= ' + convert( char(5), @sp_ano  )
				select	@squery = @squery + 'and mes_periodo		= ' + convert( char(5), @sp_mes  )
				select	@squery = @squery + 'and cod_tipo_proceso	= ''LQ'' '
				select	@squery = @squery + 'and nro_trabajador		= ' + convert( char(10), @sp_nro_trabajador  )
				select	@sparam = '@nvalorlocal decimal(13,4) output '
				execute sp_executesql @squery , @sparam,  @nvalorlocal = @nvalorlocal output
				end
			else
				begin
				select	@squery = 'select @nvalorlocal = ' + @sp_cod_dato + ' from historico_liquidac '
				select	@squery = @squery + 'where cod_empresa		= ' + convert( char(8), @sp_empresa_trab )
				select	@squery = @squery + 'and cod_planta			= ' + convert( varchar(8), @sp_planta_trab )
				select	@squery = @squery + 'and ano_periodo		= ' + convert( char(5), @sp_ano  )
				select	@squery = @squery + 'and mes_periodo		= ' + convert( char(5), @sp_mes  )
				select	@squery = @squery + 'and cod_tipo_proceso	= ''' + @sp_proceso + ''' '
				select	@squery = @squery + 'and nro_trabajador		= ' + convert( char(10), @sp_nro_trabajador  )
				select	@sparam = '@nvalorlocal decimal(13,4) output '
				execute sp_executesql @squery , @sparam,  @nvalorlocal = @nvalorlocal output
				end
			end
		end
	if @nvalorlocal is null and @sp_cod_origen <> 'P'
		begin
        select	@nvalorlocal = 0
		end
    if @sp_cod_operacion = '+'
		begin
        select	@nvalortotal = @nvalortotal + @nvalorlocal
		end
    else
		begin
        if @sp_cod_origen <> 'P'
			begin
            select	@nvalortotal = @nvalortotal - @nvalorlocal
			end
        else
			begin
            select	@nvalortotal = 0
			end
		end
    fetch cur_lib_entradas into @sp_cod_operacion, @sp_cod_origen, @sp_cod_dato, @sp_orden_operacioncol, @sp_flg_transaccion
	end 
close cur_lib_entradas
deallocate cur_lib_entradas
return 0
go
--fin splibrem_columna--