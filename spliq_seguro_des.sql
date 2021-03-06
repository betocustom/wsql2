/****** Object:  StoredProcedure [dbo].[spliq_seguro_des]    Script Date: 05/04/2018 18:27:56 ******/
DROP PROCEDURE [dbo].[spliq_seguro_des]
GO
/****** Object:  StoredProcedure [dbo].[spliq_seguro_des]    Script Date: 05/04/2018 18:27:56 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/****** Objeto:  procedimiento almacenado dbo.spliq_seguro_des    fecha de la secuencia de comandos: 25-11-2015 15:38:04 ******/
CREATE PROCEDURE [dbo].[spliq_seguro_des]
(@sp_mes_proceso int,@sp_ano_proceso int,@sp_empresa int,@sp_planta int,@sp_nro_trabajador int,
 @sp_dv_trabajador char(1),@sp_tipo_proceso char(4),@dias_proceso int,@cod_tipo_contra char(1),
 @sp_fin_informacio datetime, @sp_fec_mod_tip_con datetime,@sp_ini_informacio  datetime,
 @monto_seg_des numeric(28,10) output) 
as
declare @sp_cod_centro_cost int
declare @sp_cod_sucursal    int
declare @sp_cod_tipo_trabaj char(2)
declare @sp_tot_dctos_legal int
declare @sp_tot_dctos_no_le int
declare @sp_rut_trabajador int
declare @codigo_busco char(10), @codigo_busco_l char(10)
declare @descuento_legal_l char(1), @mes_vigente_l char(1)
declare @valor_decimal decimal(28,10), @monto_descuento_l decimal(28,10),
        @valor_tope_uf decimal(28,10), @valor_topado decimal(28,10),
        @valor_topado_tope decimal(28,10),@valor_topado_tope_prop decimal(28,10),@sp_valor_imponible int
declare @tipo_convenio_l int,@tope_uf_l decimal(28,10),@centro_costo_l int,  @cod_descuento_l int
declare @unidad_moneda_l char(4), @moneda_tope_l char(4),@sp_val_tot_tope_impon_calc numeric(28,10)
declare @tip_trabajador_l char(2)
declare @tope_minimo_l decimal(28,10),@unidad_tope_min_l char(4),@valor_topado_min decimal(28,10),
        @valor_sin_tope decimal(28,10),@sp_nro_dias_enferm int,@sp_nro_dias_vacacione int,@sp_nro_asistidos int,@sp_busca_info datetime,@nvalorcontract decimal(28,10),
        @sp_busca int,@sp_mes_lice int,@sp_ano_lice int,@sp_nro_dias_lice int,@sp_tot_impon_calc decimal(28,10),
        @ncuenta int,@sp_tot_impon_real decimal(13,4),@nfactor_cambio1 decimal(13,12),@nFactor_cambio2 decimal(13,12),
        @sp_impon_pag_emp decimal(28,10),@sp_impon_pag_trab decimal(28,10), @sp_afecto_seg numeric(28,10),
        @afecto_impto numeric(28,10),@tot_impon_otros numeric(28,10),@tot_impon_dif numeric(28,10),
        @afecto_otros numeric(28,10), @monto_tope numeric(28,10), @sp_max_impon_seguro numeric(28,10)
declare @sp_flg_revisa_hist char(1),@sp_flg_difer_tope char(1),@afecto_llss_lic char(1)
declare @sp_nro_dias_enfermo int,@sp_tot_imponible numeric(28,10),
        @sp_tot_impon_sin_tope numeric(28,10),@valor_contractual_mes numeric(28,10),
        @valor_contractual_mes_topado numeric(28,10)
declare @sp_ausentes_contrato int,@sp_dias_trab int,@sp_dias_asiste int,
        @sp_tot_impon_actualiza numeric(28,10),@sp_afecto_seg_inicial numeric(28,10),
        @sp_prop_tope_imp_seg char(1)
declare @sp_fec_ini_contrato datetime,@sp_fec_fin_contrato datetime, 
        @sp_fec_inicio datetime, @sp_fec_termino datetime
declare @bContrato int,@sp_nro_dias_asisti int 
declare @AFCDiasTrabL numeric(28,10), @AFCDiasLML numeric (28,10), @ValDiarioLML numeric (28,10)
declare @RentaImpLML numeric (28,10), @AFCTotalLML numeric (28,10), @sp_val_tot_tope_impon numeric(28,10)
declare @tot_impon_calc_AFC numeric (28,10),@mto_tope_afc_peso decimal(28,10), @sp_val_tot_tope_impon_ant numeric(28,10)
declare @sp_val_tot_impon_sin_tope_ant numeric(28,10),@sp_max_impon_seguro_ant numeric(28,10)
declare @rut_trabajador int, @cont int, @aplica_seguro_des char (1)
declare @anos_contrato int
declare @sp_fec_ini_contrat datetime
declare @fec_aplica_seguro_des datetime
declare @n_fec_ini_contrat int
declare @n_fec_aplica_seguro_des int, @nro_dias_ausente int
declare @n_cotizaciones int
declare @n_fecha_actual datetime
declare @n_fec_actual int
declare @impon_afc_ant numeric(28,10)
declare @sp_imp_afc_x numeric(28,10)
declare @sp_imp_afc_y numeric(28,10)
declare @sp_tot_impon_calc_paso numeric(28,10)
declare @sp_dif_topes numeric(28,10)

declare @cod_tipo_contra_ant char(1)
declare @cambia_cont int
declare @bModCon int

declare @sp_nombre  char(50)
declare @dias_mes int

select @cambia_cont = 0 
select  @n_fecha_actual = getdate()


select @valor_topado_tope = 0
select @valor_topado_tope_prop = 0
select @sp_nro_asistidos = 0
select @nfactor_cambio1 = 1.00
select @nFactor_cambio2 = 1.00
select @sp_ausentes_contrato = 0
select @sp_dias_trab = 0
select @sp_dias_asiste = 0
select @sp_tot_impon_actualiza = 0
select @sp_afecto_seg_inicial = 0
select @sp_max_impon_seguro = 0
select @sp_tot_impon_calc = 0
select @sp_tot_impon_real = 0
select @sp_dif_topes = 0
select @sp_imp_afc_x = 0 
select @sp_imp_afc_y = 0
select @sp_tot_impon_calc_paso = 0

select @sp_cod_sucursal       = cod_sucursal,
       @sp_cod_centro_cost    = cod_centro_costo,
       @sp_cod_tipo_trabaj    = cod_tipo_trabajado,
       @sp_nro_dias_enferm    = nro_dias_enfermo,
       @sp_nro_dias_vacacione = nro_dias_vacacione,
       @sp_nro_asistidos      = nro_dias_asistidos + nro_dias_vacacione + nro_dias_ausente,
       @sp_tot_impon_calc     = tot_impon_sin_tope,
       @sp_afecto_seg         = monto_impon_seguro,
       @afecto_impto          = afecto_impto,
       @sp_tot_impon_sin_tope = tot_impon_sin_tope,
       @sp_dias_asiste        = nro_dias_asistidos,
       @sp_fec_ini_contrato   = fec_ini_contr_vige,
       @sp_fec_fin_contrato   = fec_fin_contr,
       @sp_max_impon_seguro   = max_impon_seguro,
       @sp_nro_dias_asisti    = nro_dias_asistidos,
       @sp_val_tot_tope_impon_calc = valor_imponible,
	   @nro_dias_ausente = nro_dias_ausente
from historico_liquidac
where   cod_empresa      = @sp_empresa and
        cod_planta       = @sp_planta and
        mes_periodo      = @sp_mes_proceso and
        ano_periodo      = @sp_ano_proceso and
        cod_tipo_proceso = @sp_tipo_proceso and
        nro_trabajador   = @sp_nro_trabajador and
        dv_trabajador    = @sp_dv_trabajador

select 	@sp_nombre		= nombre,
		@sp_ausentes_contrato = ausente_contrato,
		@sp_dias_trab         = ndias_trab
from liquidacion
where   cod_empresa      = @sp_empresa and
        cod_planta       = @sp_planta and
        mes_periodo      = @sp_mes_proceso and
        ano_periodo      = @sp_ano_proceso and
        cod_tipo_proceso = @sp_tipo_proceso and
        nro_trabajador   = @sp_nro_trabajador and
        dv_trabajador    = @sp_dv_trabajador
		
select @sp_fec_inicio  = @sp_ini_informacio
select @sp_fec_termino = @sp_fin_informacio

---TIPS 26010
if @sp_nro_dias_enferm > 0
  begin
  		select top 1 
  		@sp_val_tot_tope_impon_ant=p.mto_tope_afc_peso,
  		@sp_val_tot_impon_sin_tope_ant=h.tot_impon_sin_tope
			from parametro p, historico_liquidac h
			where
			p.cod_empresa = @sp_empresa     and
			p.cod_planta  = @sp_planta      and
			h.nro_dias_enfermo = 0 and
			h.cod_empresa = p.cod_empresa and
			h.cod_planta = p.cod_planta and
			h.ano_periodo = p.ano and
			h.mes_periodo = p.nro_mes and
			h.nro_trabajador = @sp_nro_trabajador
			order by p.ano desc, p.nro_mes desc
  end

select @bContrato = 1

if @sp_fec_ini_contrato is not null
  begin
    if @sp_fec_ini_contrato >= @sp_ini_informacio and @sp_fec_ini_contrato <= @sp_fin_informacio
      select @sp_fec_inicio = @sp_fec_ini_contrato
  end
if @sp_fec_fin_contrato is not null
  begin
    if @sp_fec_fin_contrato >=@sp_ini_informacio and @sp_fec_fin_contrato <= @sp_fin_informacio
      select @sp_fec_termino = @sp_fec_fin_contrato
    else if @sp_fec_fin_contrato < @sp_ini_informacio
      select @bContrato = 0
  end

if @sp_fec_ini_contrato > @sp_fec_mod_tip_con
	begin
        select @sp_fec_mod_tip_con = ''
		insert into errores_calculo(cod_empresa,cod_planta,nro_trabajador,dv_trabajador,
			nombre,cod_error_tabla,descripcion_codigo,masivo_informado,descripcion_error,
			tabla_del_error,cod_tipo_proceso,tipo_error)
		values(@sp_empresa,@sp_planta,@sp_nro_trabajador,@sp_dv_trabajador,@sp_nombre,31,
		'Revisar Maestro Personal','C','Fecha Modif. Contrato es anterior a Fecha de Inicio Contrato',
		'Personal',@sp_tipo_proceso,'E')
	end 
	
  
----
if @sp_fec_ini_contrato > = @sp_fec_mod_tip_con
        select @sp_fec_mod_tip_con = ''


select @dias_mes = @dias_proceso
--- (datepart(dd,@sp_fec_termino) - datepart(dd,@sp_fec_inicio ))+1



	select top 1 @cod_tipo_contra_ant = codigo_tipo_contra
	from historico_personal
	where
	cod_empresa    = @sp_empresa and
	cod_planta     = @sp_planta  and
	nro_trabajador = @sp_nro_trabajador and
	dv_trabajador = @sp_dv_trabajador
	order by ano_periodo desc, mes_periodo desc

if @sp_fec_mod_tip_con is not null and @sp_fec_mod_tip_con >= @sp_fec_inicio
   begin
	if (@sp_fec_mod_tip_con > @sp_fec_ini_contrato) and (@sp_fec_mod_tip_con < = @sp_fec_termino)
		begin
		if @cod_tipo_contra = 'P'
			begin
				select @nFactor_cambio2 = (((datepart(dd,@sp_fec_termino) - datepart(dd,@sp_fec_mod_tip_con))+1)*1.0) / @dias_mes
			end
		if @cod_tipo_contra != 'P' 
			begin
				select @nFactor_cambio2 = ((datepart(dd,@sp_fec_mod_tip_con) - datepart(dd,@sp_fec_inicio ) )*1.0) / @dias_mes
			end
		end
   end 
else
   begin
	if @cod_tipo_contra = 'P'
		select @nFactor_cambio2 = 1
	else
		select @nFactor_cambio2 = 0
end



if @sp_fec_mod_tip_con is not null and  @sp_fec_mod_tip_con >= @sp_fec_inicio and @sp_fec_mod_tip_con <= @sp_fec_termino
  begin
	if (@cod_tipo_contra_ant = 'F' or @cod_tipo_contra_ant='O') and (@cod_tipo_contra ='O' or @cod_tipo_contra ='F') and not @cod_tipo_contra ='P'
		select @nFactor_cambio2 = 0
	if  (@cod_tipo_contra_ant = 'P' and @cod_tipo_contra='P')
		select @nFactor_cambio2 = 1
  end

if @sp_fec_mod_tip_con > @sp_fec_termino
	if (@cod_tipo_contra_ant != 'P') 
	select @nFactor_cambio2 = 0


select @sp_afecto_seg_inicial = @sp_afecto_seg


select @sp_flg_revisa_hist   = flg_revisa_hist,
       @sp_flg_difer_tope    = flg_difer_tope,
       @sp_prop_tope_imp_seg = prop_tope_imp_seg
from control_parametros
where cod_empresa        = @sp_empresa and 
      cod_planta         = @sp_planta and
      mes_control_proces = @sp_mes_proceso and
      ano_control_proces = @sp_ano_proceso

if (@sp_flg_revisa_hist    is null or @sp_flg_revisa_hist   = ' ' ) select @sp_flg_revisa_hist    = 'N'
if (@sp_flg_difer_tope     is null or @sp_flg_difer_tope    = ' ' ) select @sp_flg_difer_tope     = 'N'
if (@sp_prop_tope_imp_seg  is null or @sp_prop_tope_imp_seg = ' ' ) select @sp_prop_tope_imp_seg  = 'N'

select @valor_topado_tope = mto_tope_afc_peso 
from
parametro
where 
cod_empresa        = @sp_empresa and 
cod_planta         = @sp_planta and
nro_mes            = @sp_mes_proceso and
ano                = @sp_ano_proceso

if @sp_nro_dias_enferm > 0 and @sp_prop_tope_imp_seg = 'S' 
   select @valor_topado_tope_prop = round(( @valor_topado_tope * ( @sp_nro_asistidos + @sp_nro_dias_vacacione )) / 30,0)
else
   select @valor_topado_tope_prop = @valor_topado_tope


select @afecto_llss_lic = afecto_llss_lic
from param_licencia
where
cod_empresa = @sp_empresa and
cod_planta  = @sp_planta 

if @afecto_llss_lic is null select @afecto_llss_lic = 'N'

select 
            @valor_contractual_mes = sum(isnull(valor_transac_peso,0))
            from haberes_contractua
            where cod_empresa = @sp_empresa and
            cod_planta        = @sp_planta and
            cod_tipo_proceso  = @sp_tipo_proceso and
            ano_periodo       = @sp_ano_proceso  and
			mes_periodo       = @sp_mes_proceso  and
            nro_trabajador    = @sp_nro_trabajador and
            dv_trabajador     = @sp_dv_trabajador and
            cod_haber in (select cod_haber from haber where cod_empresa=@sp_empresa and
                      cod_planta=@sp_planta and concepto_imponible='S')



if @valor_contractual_mes is null select @valor_contractual_mes =0
if @valor_contractual_mes > @valor_topado_tope
  select @valor_contractual_mes_topado = @valor_topado_tope
else
  select @valor_contractual_mes_topado = @valor_contractual_mes


--Nuevo
if @afecto_llss_lic = 'N' and ( @sp_nro_dias_enferm >= 30 or  ( @sp_nro_dias_enferm + @sp_ausentes_contrato = @dias_proceso ))
  begin
    select @sp_tot_impon_real = 0
    select @sp_tot_impon_calc = 0
  end
else if @sp_flg_difer_tope = 'N'
  begin
    if @afecto_llss_lic = 'S' and ( @sp_nro_dias_enferm + @sp_ausentes_contrato = @dias_proceso )
      begin
        if @sp_dias_asiste = 0 and @sp_nro_dias_enferm+ @sp_ausentes_contrato = @dias_proceso and 
           @valor_contractual_mes > @valor_topado_tope and ( @bContrato = 1 or @sp_tot_impon_sin_tope > 0 )
          begin
            if @sp_tot_impon_sin_tope = 0
              select @sp_tot_impon_calc = 0
            else
              begin
                if @sp_prop_tope_imp_seg = 'N' 
                  select @sp_tot_impon_calc = @sp_tot_impon_calc
                else
                  select @sp_tot_impon_calc = @valor_topado_tope
              end
          end          
        else if @sp_dias_asiste = 0 and @sp_nro_dias_enferm+ @sp_ausentes_contrato  = @dias_proceso and 
           @valor_contractual_mes <= @valor_topado_tope
           select @sp_tot_impon_calc = @sp_tot_impon_calc
        else
           select @sp_tot_impon_calc = 0
      end
    else
      begin
        if @valor_contractual_mes > @valor_topado_tope
          if @sp_nro_dias_enferm > 0 and @sp_prop_tope_imp_seg = 'S'
            begin
              select @sp_tot_impon_calc = round(@valor_topado_tope_prop,0)
            end
          else
            if @sp_tot_impon_calc > @valor_topado_tope
              select @sp_tot_impon_calc = round(@valor_topado_tope,0)
            else
              select @sp_tot_impon_calc = round(@sp_tot_impon_calc,0)
        else
          select @sp_tot_impon_calc = round(@sp_tot_impon_calc,0)
      end
  end

if @sp_flg_difer_tope = 'N'
  begin
    if @sp_nro_dias_asisti > 0 
      begin
      --TIPS 26010
		  if @sp_tot_impon_calc >= @valor_topado_tope
		  begin
				if @valor_topado_tope_prop >= @sp_tot_impon_calc and @sp_prop_tope_imp_seg = 'S'
				begin
				  --select @sp_max_impon_seguro = @val_tope_90uf - (@val_tope_90uf * @sp_nro_dias_enfermo ) / 30 - @val_afecto_cotiza_seg
				  select @sp_max_impon_seguro = @valor_topado_tope_prop - @sp_tot_impon_calc
				end
				else if @valor_topado_tope_prop >= @sp_tot_impon_calc and @sp_prop_tope_imp_seg = 'N'
				begin
				  select @sp_max_impon_seguro = @valor_topado_tope - @sp_tot_impon_calc
				end
				else
				begin
				  select @sp_max_impon_seguro = 0
				end
		   end
		   else
		   begin
		   		if @sp_prop_tope_imp_seg = 'S'
				begin
				  --select @sp_max_impon_seguro = @val_tope_90uf - (@val_tope_90uf * @sp_nro_dias_enfermo ) / 30 - @val_afecto_cotiza_seg
				  --select @sp_max_impon_seguro = @valor_topado_tope - @sp_val_tot_impon_sin_tope_ant-@sp_tot_impon_calc
				  select @sp_max_impon_seguro = @valor_topado_tope_prop - @sp_tot_impon_calc
				end
				else if @sp_prop_tope_imp_seg = 'N'
				begin
				  select @sp_max_impon_seguro = @valor_topado_tope - @sp_tot_impon_calc
				end
				else
				begin
				  select @sp_max_impon_seguro = 0
				end
		   end
	   end
    else
      begin
        if @afecto_llss_lic = 'N'
          select @sp_max_impon_seguro = @valor_contractual_mes_topado - @sp_tot_impon_calc
        else
          if @sp_prop_tope_imp_seg = 'S'
            select @sp_max_impon_seguro = @valor_topado_tope - @valor_contractual_mes_topado
          else
            select @sp_max_impon_seguro = @valor_topado_tope - @sp_tot_impon_calc
      end
  end
    

--Nuevo

select @sp_rut_trabajador = rut_trabajador,
@aplica_seguro_des = aplica_seguro_des,
@sp_fec_ini_contrat = fec_ini_contrato,
@fec_aplica_seguro_des = fec_ini_seguro_des
from personal
where
cod_empresa    = @sp_empresa and
cod_planta     = @sp_planta  and
nro_trabajador = @sp_nro_trabajador

if @sp_flg_revisa_hist ='C'
   begin
     select @tot_impon_otros = sum(isnull(monto_impon_seguro,0)),@sp_max_impon_seguro_ant= sum(isnull(max_impon_seguro,0))
     from historico_liquidac a, personal b
     where 
     ( (a.cod_empresa   = @sp_empresa and
     a.cod_planta       != @sp_planta and
     a.mes_periodo      = @sp_mes_proceso and
     a.ano_periodo      = @sp_ano_proceso ) or
     (a.cod_empresa     = @sp_empresa and
     a.cod_planta       = @sp_planta and
     a.mes_periodo      = @sp_mes_proceso and
     a.ano_periodo      = @sp_ano_proceso and
     a.nro_trabajador   != @sp_nro_trabajador) )  and
     a.cod_tipo_proceso in (select p.cod_tipo_proceso from tipo_proceso p where p.flg_proceso_lq='S') and
     a.cod_empresa      = b.cod_empresa and
     a.cod_planta       = b.cod_planta and
     a.nro_trabajador   = b.nro_trabajador and
     a.dv_trabajador    = b.dv_trabajador and
     b.rut_trabajador   = @sp_rut_trabajador
     
     select @tot_impon_dif = sum(isnull(monto_impon_seguro,0))
     from hist_diferencias a, personal b
     where
     ( (a.cod_empresa   =  @sp_empresa and
     a.cod_planta       != @sp_planta and
     a.mes_periodo      =  @sp_mes_proceso and
     a.ano_periodo      =  @sp_ano_proceso ) or
     (a.cod_empresa     =  @sp_empresa and
     a.cod_planta       =  @sp_planta and
     a.mes_periodo      =  @sp_mes_proceso and
     a.ano_periodo      =  @sp_ano_proceso and
     a.nro_trabajador   != @sp_nro_trabajador) )  and
     a.cod_tipo_proceso in (select p.cod_tipo_proceso from tipo_proceso p where p.flg_proceso_lq='S') and
     a.cod_empresa      = b.cod_empresa and
     a.cod_planta       = b.cod_planta and
     a.nro_trabajador   = b.nro_trabajador and
     a.dv_trabajador    = b.dv_trabajador and
     b.rut_trabajador   = @sp_rut_trabajador
  end
if @sp_flg_revisa_hist ='E'
  begin
    select @tot_impon_otros = sum(isnull(monto_impon_seguro,0)),@sp_max_impon_seguro_ant= sum(isnull(max_impon_seguro,0))
    from historico_liquidac a, personal b
    where
    a.cod_empresa       = @sp_empresa and
    a.cod_planta        = @sp_planta and
    a.mes_periodo       = @sp_mes_proceso and
    a.ano_periodo       = @sp_ano_proceso and
    a.nro_trabajador   != @sp_nro_trabajador and
    a.cod_tipo_proceso in (select p.cod_tipo_proceso from tipo_proceso p where p.flg_proceso_lq='S') and
    a.cod_empresa       = b.cod_empresa and
    a.cod_planta        = b.cod_planta and
    a.nro_trabajador    = b.nro_trabajador and
    a.dv_trabajador     = b.dv_trabajador and
    b.rut_trabajador    = @sp_rut_trabajador      

    select @tot_impon_dif = sum(isnull(monto_impon_seguro,0))
    from hist_diferencias a, personal b
    where 
    a.cod_empresa       = @sp_empresa and
    a.cod_planta        = @sp_planta and
    a.mes_periodo       = @sp_mes_proceso And
    a.ano_periodo       = @sp_ano_proceso And
    a.nro_trabajador   != @sp_nro_trabajador and
    a.cod_tipo_proceso in (select p.cod_tipo_proceso from tipo_proceso p where p.flg_proceso_lq='S') and
    a.cod_empresa       = b.cod_empresa and
    a.cod_planta        = b.cod_planta and
    a.nro_trabajador    = b.nro_trabajador and
    a.dv_trabajador     = b.dv_trabajador and
    b.rut_trabajador    = @sp_rut_trabajador
  end
if @sp_flg_revisa_hist ='P'
   begin
    select @tot_impon_otros = sum(isnull(monto_impon_seguro,0)),@sp_max_impon_seguro_ant= sum(isnull(max_impon_seguro,0))
    from historico_liquidac a, personal b
    where 
    ( (a.cod_empresa = @sp_empresa and
    a.cod_planta != @sp_planta and
    a.mes_periodo = @sp_mes_proceso and
    a.ano_periodo = @sp_ano_proceso ) or
    (a.cod_empresa = @sp_empresa and
    a.cod_planta = @sp_planta and
    a.mes_periodo = @sp_mes_proceso and
    a.ano_periodo = @sp_ano_proceso and
    a.nro_trabajador != @sp_nro_trabajador) or 
   (a.cod_empresa != @sp_empresa and
    a.mes_periodo = @sp_mes_proceso and
    a.ano_periodo = @sp_ano_proceso ) )  and
    a.cod_tipo_proceso in (select p.cod_tipo_proceso from tipo_proceso p where p.flg_proceso_lq='S') and
    a.cod_empresa=b.cod_empresa and
    a.cod_planta=b.cod_planta and
    a.nro_trabajador=b.nro_trabajador and
    a.dv_trabajador=b.dv_trabajador and
    b.rut_trabajador = @sp_rut_trabajador    
    

    select @tot_impon_dif = sum(isnull(monto_impon_seguro,0))
    from hist_diferencias a, personal b
    where
    ( (a.cod_empresa = @sp_empresa and
    a.cod_planta != @sp_planta and
    a.mes_periodo = @sp_mes_proceso and
    a.ano_periodo = @sp_ano_proceso ) or
    (a.cod_empresa = @sp_empresa and
    a.cod_planta = @sp_planta and
    a.mes_periodo = @sp_mes_proceso and
    a.ano_periodo = @sp_ano_proceso and
    a.nro_trabajador != @sp_nro_trabajador) or 
   (a.cod_empresa != @sp_empresa and
    a.mes_periodo = @sp_mes_proceso and
    a.ano_periodo = @sp_ano_proceso ) )  and
    a.cod_tipo_proceso in (select p.cod_tipo_proceso from tipo_proceso p where p.flg_proceso_lq='S') and
    a.cod_empresa=b.cod_empresa and
    a.cod_planta=b.cod_planta and
    a.nro_trabajador=b.nro_trabajador and
    a.dv_trabajador=b.dv_trabajador and
    b.rut_trabajador = @sp_rut_trabajador
   end

if  @tot_impon_otros is null select @tot_impon_otros = 0
if  @tot_impon_dif   is null select @tot_impon_dif   = 0

select @afecto_otros= @tot_impon_otros + @tot_impon_dif

select @anos_contrato=convert(int,datediff(yy,@sp_fec_ini_contrat,getdate()))

if @afecto_llss_lic = 'N' and ( @sp_nro_dias_enferm >= 30 or ( @sp_nro_dias_enferm + @sp_ausentes_contrato = @dias_proceso ))
--and  @valor_topado_tope_prop = 0
 begin
    select @sp_tot_impon_real = 0
    select @sp_tot_impon_calc = 0
  end



if @afecto_otros > 0
   begin
      select @monto_tope = @valor_topado_tope_prop
      if @afecto_otros > @monto_tope
         begin
            select @valor_topado_tope_prop = 0
            select @sp_tot_impon_calc = 0
         end
      else
         begin
            if ( @afecto_otros + @sp_tot_impon_calc ) > @monto_tope
               begin
                  select @valor_topado_tope_prop = @monto_tope - @tot_impon_otros
                  select @sp_tot_impon_calc = @monto_tope - @tot_impon_otros
               end
         end
   end
   
--HERE
--if @sp_tot_impon_calc > @valor_topado_tope_prop
  -- select @sp_tot_impon_calc = @valor_topado_tope_prop

  --Corrige m ximos con licencia
  IF (@sp_tot_impon_calc >= round((isnull(@valor_topado_tope,0) * ( @sp_nro_dias_asisti + @sp_nro_dias_vacacione) ) / 30,0)) 
	and @sp_nro_dias_enferm > 0 and @sp_flg_difer_tope = 'N'
	select @sp_max_impon_seguro = 0
	
 --Corrige m ximos
  --select @rut_trabajador=rut_trabajador from personal where nro_trabajador = @sp_nro_trabajador
		--and cod_empresa = @sp_empresa and cod_planta = @sp_planta








--group by rut_trabajador

	if @sp_tot_impon_calc >= @valor_topado_tope
		select @sp_tot_impon_calc = @valor_topado_tope

if @sp_flg_revisa_hist != 'N' --and @sp_tot_impon_sin_tope >=@sp_tot_imponible
  begin

select @cont=COUNT(rut_trabajador) 
from personal where rut_trabajador = @rut_trabajador 
and cod_vigen_trabajad = 'S'
If @cont > 1 
begin
select @cont=COUNT(rut_trabajador) 
from personal where rut_trabajador = @rut_trabajador 
and cod_vigen_trabajad = 'S'
	if @sp_tot_impon_calc >= @valor_topado_tope
		begin
			select @sp_max_impon_seguro = 0
		end
	else
		begin
			if @sp_flg_difer_tope = 'S' and @sp_nro_dias_enferm > 0
					select @sp_max_impon_seguro = @valor_topado_tope-@sp_tot_impon_calc-@tot_impon_otros-@sp_max_impon_seguro_ant
		else if @sp_flg_difer_tope = 'S' and @sp_nro_dias_enferm = 0
				begin
					if @sp_max_impon_seguro_ant > 0
						begin
							select @sp_max_impon_seguro = @valor_topado_tope-@sp_tot_impon_calc-@tot_impon_otros-@sp_max_impon_seguro_ant
							select @sp_tot_impon_calc = round((@sp_tot_impon_calc),0)
							select @sp_tot_impon_actualiza = round((@sp_afecto_seg_inicial),0)
						end
					else
						begin
							select @sp_max_impon_seguro = @valor_topado_tope-@sp_tot_impon_calc-@tot_impon_otros
							select @sp_tot_impon_calc = round((@sp_tot_impon_calc),0)
							select @sp_tot_impon_actualiza = round((@sp_afecto_seg_inicial),0)
						end
				end
		else
			select @sp_max_impon_seguro = @valor_topado_tope-@sp_tot_impon_calc-@tot_impon_otros
	end
end	

end

if @sp_max_impon_seguro < 0
 select @sp_max_impon_seguro = 0

select @sp_tot_impon_real = @sp_tot_impon_calc

select @sp_tot_dctos_legal = 0
select @sp_tot_dctos_no_le = 0

select @valor_decimal = 0
select @valor_tope_uf = 0
select @valor_topado  = 0

select @cod_descuento_l = 509

select @tope_uf_l         = tope_uf,
       @mes_vigente_l     = cod_mes_vigente,
       @moneda_tope_l     = cod_unidad_tope,
       @descuento_legal_l = descuento_legal,
       @tope_minimo_l     = tope_minimo,
       @unidad_tope_min_l = unidad_tope_min,
       @monto_descuento_l = mto_descuento,
       @unidad_moneda_l   = cod_unidad_moneda
from descuento
where cod_empresa   = @sp_empresa and
      cod_planta    = @sp_planta and
      cod_descuento = @cod_descuento_l
      
if @tope_uf_l     is null select @tope_uf_l     = 0
if @tope_minimo_l is null select @tope_minimo_l = 0

select @valor_decimal = 0
select @valor_tope_uf = 0
select @valor_topado  = 0
select @codigo_busco = ''

select @sp_busca_info = @sp_fin_informacio
select @nvalorcontract = 0
select @valor_decimal = 0

if @sp_nro_dias_enferm > 0 
  begin
    select @sp_busca = 0
    if @sp_mes_proceso = 1
      begin
        select @sp_mes_lice = 12
        select @sp_ano_lice = @sp_ano_proceso - 1
      end
    else
      begin
        select @sp_mes_lice = @sp_mes_proceso -1
        select @sp_ano_lice = @sp_ano_proceso
      end
   
    select @ncuenta = 0
    select @sp_nro_dias_lice = 1
  
  while @sp_busca=0 and @sp_nro_dias_lice != 0
      begin
		
        select @sp_nro_dias_lice   = null  
        select @sp_nro_dias_lice  = nro_dias_enfermo,
               @sp_tot_impon_real = tot_impon_sin_tope,
			   @impon_afc_ant = monto_impon_seguro
        from historico_liquidac
        where
          cod_empresa      = @sp_empresa and
          cod_planta       > 0 and
          ano_periodo      = @sp_ano_lice and
          mes_periodo      = @sp_mes_lice and
          cod_tipo_proceso = @sp_tipo_proceso and
          nro_trabajador   = @sp_nro_trabajador and
          dv_trabajador    = @sp_dv_trabajador
        	   	
		if @sp_nro_dias_lice=0 or @sp_nro_dias_lice is null
          begin
            select @sp_busca=1
          end
        else
          begin
            if @sp_mes_lice = 1
              begin
                select @sp_mes_lice = 12
                select @sp_ano_lice= @sp_ano_lice - 1
              end
            else
              begin
                select @sp_mes_lice = @sp_mes_lice - 1
              end
          end
      end
    if @sp_nro_dias_lice = 0
      begin
        select @sp_busca_info = fec_fin_info_perio
        from control_procesos
        where 
        control_procesos.cod_empresa        = @sp_empresa and
        control_procesos.cod_planta         = @sp_planta and
        control_procesos.ano_proc_cont_proc = @sp_ano_lice and
        control_procesos.cod_mes_proceso    = @sp_mes_lice
      end
    else
      begin
        select @nvalorcontract = isnull(sum(valor_transac_peso),0) 
        from haberes_contractua, haber
        where
        haberes_contractua.cod_empresa      = haber.cod_empresa and 
        haberes_contractua.cod_planta       = haber.cod_planta and
        haberes_contractua.cod_haber        = haber.cod_haber and        
        haberes_contractua.cod_empresa      = @sp_empresa and
        haberes_contractua.cod_planta       = @sp_planta  and
        haberes_contractua.ano_periodo      = @sp_ano_proceso and 
        haberes_contractua.mes_periodo      = @sp_mes_proceso and
        haberes_contractua.cod_tipo_proceso = @sp_tipo_proceso and
        haberes_contractua.nro_trabajador   = @sp_nro_trabajador and
        haberes_contractua.dv_trabajador    = @sp_dv_trabajador and
        haber.concepto_imponible            = 'S'
		
        select @sp_tot_impon_real = @nvalorcontract


      end
  end
  
 if @sp_afecto_seg > 0 and @sp_flg_difer_tope = 'S' and @sp_nro_dias_enferm > 0 --1-4
  select @sp_tot_impon_calc = @sp_afecto_seg
 
if @sp_afecto_seg = 0 and @sp_flg_difer_tope = 'S' and @sp_nro_dias_enferm > 0
	 select @sp_tot_impon_calc = 0
 
 
--Nuevo c lculo de AFC 2012

if @sp_nro_dias_enferm > 0
	begin  
		if @afecto_llss_lic = 'N' and ( @sp_nro_dias_enferm >= 30 or ( @sp_nro_dias_enferm + @sp_ausentes_contrato = @dias_proceso ))
		AND @valor_topado_tope_prop = 0
		begin
----print 'if 1' 
			select @sp_tot_impon_real = 0
			select @sp_tot_impon_calc = 0
		end
		select @mto_tope_afc_peso  = mto_tope_afc_peso
		from parametro
		where
		cod_empresa = @sp_empresa     and
		cod_planta  = @sp_planta      and
		ano         = @sp_ano_proceso and
		nro_mes     = @sp_mes_proceso  
	
	--TIPS 26010 VALIDACION FEBRERO
		if @sp_nro_dias_enferm = DATEPART(day,@sp_fin_informacio) and @sp_mes_proceso = 2
			--begin
			set @sp_nro_dias_enferm = 30
			
			
			--select @tot_impon_calc_AFC = round((@sp_tot_impon_calc/30*@sp_nro_dias_enferm),0) + @sp_val_tot_tope_impon_calc--round((@sp_val_tot_tope_impon/30*(@sp_nro_dias_asistidos + @sp_nro_dias_vacacione)),0) 
			select @tot_impon_calc_AFC = round((@sp_tot_impon_calc/30*@sp_nro_dias_enferm),0) + @sp_val_tot_tope_impon_calc--round((@sp_val_tot_tope_impon/30*(@sp_nro_dias_asistidos + @sp_nro_dias_vacacione)),0) 

			
			if @tot_impon_calc_AFC > @mto_tope_afc_peso
					select @tot_impon_calc_AFC = @mto_tope_afc_peso
			select @AFCTotalLML=round((@tot_impon_calc_AFC * ( @monto_descuento_l / 100.00)),0)
			
			if @AFCTotalLML > round((@mto_tope_afc_peso * ( @monto_descuento_l / 100.00)),0)
				select @valor_decimal=round((@mto_tope_afc_peso * ( @monto_descuento_l / 100.00)),0)
			else
				select @valor_decimal=@AFCTotalLML
		--	end
end
		------------------------------------------------



if @monto_descuento_l > 0 
   begin
		
		if @monto_descuento_l > 0 and @sp_tot_impon_calc=0	
			 select @sp_tot_impon_calc=@tot_impon_calc_AFC
	  if @sp_tot_impon_calc > 0  --and @cod_tipo_contra ='P'
         begin

            if @unidad_moneda_l = '%IMS'
               begin
                  select @valor_decimal = round(round(@sp_tot_impon_calc * @nFactor_cambio2,4) *  (@monto_descuento_l / 100.),0)
			   end
            else
               begin
                  select @valor_decimal = 0
               end
            if @tope_minimo_l != 0 and @unidad_tope_min_l is not null
               begin
                  exec  spliq_valores_mon @sp_mes_proceso, @sp_ano_proceso, @sp_empresa,@sp_planta,
                        @sp_nro_trabajador, @sp_dv_trabajador,@sp_tipo_proceso, @tope_minimo_l,
                        @unidad_tope_min_l,0, @sp_fin_informacio,@codigo_busco_l,'','',@valor_topado_min output
               
                  select @valor_topado_min = round((@valor_topado_min  * @nFactor_cambio2),20)
               
                  if  @valor_decimal < @valor_topado_min
                     begin
                        select @valor_sin_tope = round(@valor_decimal,0)
                        select @valor_decimal  = @valor_topado_min
                     end
               end
			   
						   

				
			
			
           if @tope_uf_l != 0 and @moneda_tope_l is not null  
               begin
                  exec  spliq_valores_mon @sp_mes_proceso, @sp_ano_proceso, @sp_empresa,@sp_planta,
                        @sp_nro_trabajador, @sp_dv_trabajador,@sp_tipo_proceso, @tope_uf_l, @moneda_tope_l,
                        0, @sp_fin_informacio,@codigo_busco_l,'','',@valor_tope_uf output
                
                  select @valor_tope_uf  = round((@valor_tope_uf   * @nFactor_cambio2),20)
               
                  if  @valor_decimal > @valor_tope_uf
                     begin
                        select @valor_sin_tope = round(@valor_decimal,0)
                        select @valor_decimal =  @valor_tope_uf
                     end
               end
			   

            if @tope_minimo_l != 0 or @tope_uf_l != 0
               begin
                  select @tope_minimo_l = round(@tope_minimo_l,0)
                  select @valor_tope_uf = round(@valor_tope_uf,0)
                  if  @valor_tope_uf != 0
                     begin
                        insert into descuentos_topados(cod_empresa,cod_planta,mes_periodo,ano_periodo,
                        cod_tipo_proceso,nro_trabajador,dv_trabajador,cod_descuento,valor_total,
                        valor_descontado) values(@sp_empresa,@sp_planta,@sp_mes_proceso,@sp_ano_proceso,
                        @sp_tipo_proceso,@sp_nro_trabajador,@sp_dv_trabajador,@cod_descuento_l,
                        @valor_sin_tope,@valor_tope_uf)
                     end
                  else
                     begin
                        insert into descuentos_topados(cod_empresa,cod_planta,mes_periodo,ano_periodo,
                        cod_tipo_proceso,nro_trabajador,dv_trabajador,cod_descuento,valor_total,
                        valor_descontado) values(@sp_empresa,@sp_planta,@sp_mes_proceso,@sp_ano_proceso,
                        @sp_tipo_proceso,@sp_nro_trabajador,@sp_dv_trabajador,@cod_descuento_l,
                        @valor_sin_tope,@tope_minimo_l)
                     end
               end
             
	    
		select @n_fec_ini_contrat=datepart(yyyy, @sp_fec_ini_contrat )*10000 + datepart(mm, @sp_fec_ini_contrat)*100 + datepart(dd, @sp_fec_ini_contrat)
		select @n_fec_aplica_seguro_des=datepart(yyyy, @fec_aplica_seguro_des )*10000+ datepart(mm, @fec_aplica_seguro_des)*100 + datepart(dd, @fec_aplica_seguro_des)
		select @n_fec_actual = datepart (yyyy, @sp_fin_informacio )*10000 + datepart(mm, @sp_fin_informacio)*100 + datepart(dd, @sp_fin_informacio)
		select @n_cotizaciones = round((((@n_fec_actual - @n_fec_aplica_seguro_des)/10000) * 12),0)

     
		if (@anos_contrato > = 11 or @n_fec_ini_contrat <= 20021002) and  (@n_fec_aplica_seguro_des <= 20021002 or @n_cotizaciones > =  132)
			  select @valor_decimal  = 0 
			
            --SEGURO DESEMPLEO PARA MESES SIN DIAS TRABAJADOS (TIPS 25756)
            if @valor_decimal > 0 --and @sp_dias_asiste > 0
               begin
                  select @valor_decimal = round(@valor_decimal, 0)
                  if @descuento_legal_l = 'S'
                     select @sp_tot_dctos_legal = @sp_tot_dctos_legal + @valor_decimal
                  else
                     select @sp_tot_dctos_no_le = @sp_tot_dctos_no_le + @valor_decimal
               end
			end 
      
				
	  
		
	  
				  exec spliq_car_descuen @sp_mes_proceso, @sp_ano_proceso, @sp_empresa,
                  @sp_planta, @sp_nro_trabajador,@sp_dv_trabajador,@sp_tipo_proceso,
                  @valor_decimal,@cod_descuento_l
				  


                  exec spliq_inserta_des @sp_mes_proceso, @sp_ano_proceso,@sp_empresa,@sp_planta,
                  @sp_nro_trabajador,@sp_dv_trabajador,@sp_tipo_proceso,@cod_descuento_l,@monto_descuento_l,
                  @unidad_moneda_l,@valor_decimal,@sp_cod_centro_cost,0,'',@sp_cod_centro_cost,
                  @sp_cod_tipo_trabaj, @sp_cod_sucursal,0,0,'', null
	  
	  if @cod_tipo_contra !='P' and @sp_fec_mod_tip_con is null 
         begin
            select @sp_tot_dctos_legal = 0
            select @sp_tot_dctos_no_le = 0
            select @valor_decimal      = 0
         end
     

	  
	  select @sp_valor_imponible = round(@sp_tot_impon_calc,0)
      select @sp_tot_dctos_legal = round(@sp_tot_dctos_legal,0)
      select @sp_tot_dctos_no_le = round(@sp_tot_dctos_no_le,0)
      select @valor_decimal      = round(@valor_decimal,0)
      select @sp_tot_impon_calc  = round(@sp_tot_impon_calc,0)

	
	
      if @sp_tot_impon_real > @valor_topado_tope_prop
         select @sp_tot_impon_real=@valor_topado_tope_prop
   
      select @afecto_impto = @afecto_impto - @valor_decimal
      if @afecto_impto < 0
              select @afecto_impto = 0
	
	  
	  
	  
	  	  
      select @monto_seg_des = @valor_decimal

      if @sp_flg_difer_tope = 'S'  and @sp_nro_dias_enferm = 0--and @sp_fec_fin_contrato < @sp_fin_informacio --
        select @sp_tot_impon_actualiza = @sp_afecto_seg_inicial
      else --if @sp_flg_difer_tope = 'N' --and @sp_fec_fin_contrato < @sp_fin_informacio --and @sp_nro_dias_enferm > 0
        select @sp_tot_impon_actualiza = @sp_tot_impon_calc
        
      
	    
	  
      --SEGURO DESEMPLEO PARA MESES SIN DIAS TRABAJADOS (TIPS 25756)
      if @sp_dias_asiste + @sp_nro_dias_vacacione = 0 and @sp_flg_difer_tope = 'N'
      begin
		select @sp_tot_impon_calc=@sp_tot_impon_calc-@sp_tot_impon_actualiza
		select @sp_max_impon_seguro = @mto_tope_afc_peso-@sp_val_tot_impon_sin_tope_ant-@sp_tot_impon_calc
	  end
	  


if @sp_tot_impon_actualiza < 0 or @sp_tot_impon_actualiza is null
	select @sp_tot_impon_actualiza = 0
if @sp_tot_impon_calc < 0 or @sp_tot_impon_calc is null
	select @sp_tot_impon_calc = 0


      update historico_liquidac
      set tot_dctos_legales = tot_dctos_legales  + @sp_tot_dctos_legal,
      tot_dctos_no_legal    = tot_dctos_no_legal + @sp_tot_dctos_no_le,
      val_leyes_sociales    = val_leyes_sociales + @valor_decimal,
      afecto_impto          = @afecto_impto,
      monto_impon_seguro    = @sp_tot_impon_actualiza,
      valor_imponible       = @sp_tot_impon_calc,
      max_impon_seguro      = @sp_max_impon_seguro,
	  mto_imp_aporte_afc	= @sp_tot_impon_actualiza
	  where 
      cod_empresa      = @sp_empresa and
      cod_planta       = @sp_planta and
      nro_trabajador   = @sp_nro_trabajador and
      dv_trabajador    = @sp_dv_trabajador and      
      mes_periodo      = @sp_mes_proceso and
      ano_periodo      = @sp_ano_proceso and
      cod_tipo_proceso = @sp_tipo_proceso

   end 
return


















GO
