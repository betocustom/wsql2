/****** Object:  StoredProcedure [dbo].[spliq_externo_h]    Script Date: 12/22/2015 19:16:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spliq_externo_h]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spliq_externo_h]
GO


/****** Object:  StoredProcedure [dbo].[spliq_externo_h]    Script Date: 12/22/2015 19:16:47 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[spliq_externo_h]
(@sp_mes_proceso int, @sp_ano_proceso int,@sp_empresa int, @sp_planta int,
 @sp_nro_trabajador int, @sp_dv_trabajador char(1),@sp_tipo_proceso char(4),
 @descuento_grabo int, @cantidad numeric(28,10), @moneda char(4), @centro_costo int,
 @sp_cod_tipo_trabaj char(2),@sp_cod_sucursal int,@retorno numeric(28,10) output,
 @retorno_no_prop numeric(28,10) output, @monto_haber_ll numeric(28,10) output,
 @unidad_moneda_ll char(4) output)
as
declare @valor_retorno numeric(28,10), @rutina_l char(30), @prop_dias char(1),
@fec_fin_info datetime, @sp_cod_convenio int, @nValor  numeric(28,10),
@proporcion_dias_trab decimal(13,12), @fec_ini_info datetime, @cantidad_tope decimal(13,4),
@moneda_tope char(4),@usuario char(10), @horas decimal(13,4)

select @monto_haber_ll   = @cantidad
select @unidad_moneda_ll = @moneda

select @fec_fin_info         = fec_final,
       @fec_ini_info         = fec_inicio,
       @sp_cod_convenio      = convenio,
       @proporcion_dias_trab = dias_proporcional
from liquidacion
where 
cod_empresa      = @sp_empresa        and
cod_planta       = @sp_planta         and
mes_periodo      = @sp_mes_proceso    and
ano_periodo      = @sp_ano_proceso    and
cod_tipo_proceso = @sp_tipo_proceso   and
nro_trabajador   = @sp_nro_trabajador and
dv_trabajador    = @sp_dv_trabajador

select 
@rutina_l      = rutina,
@prop_dias     = proporcional_dias,
@cantidad_tope = tope_uf,
@moneda_tope   = cod_unidad_tope
from haber
where
cod_empresa = @sp_empresa and
cod_planta  = @sp_planta  and
cod_haber   = @descuento_grabo


if @rutina_l = 'sp_haber_prom_comi_feri'
	begin
	exec sp_haber_prom_comi_feri	@sp_empresa,@sp_planta,@sp_mes_proceso,@sp_ano_proceso,@sp_nro_trabajador,
							@sp_dv_trabajador,@sp_tipo_proceso,@cantidad,@moneda,@descuento_grabo,
         					@fec_ini_info,@fec_fin_info,@valor_retorno output

   	select 	@retorno = round( @valor_retorno, 20 )
	select 	@retorno_no_prop = round( @valor_retorno, 20 )
	return 0	
  end

if @rutina_l = 'sp_comis_prom_vacaci'
	begin
	exec sp_haber_prom_comi_feri	@sp_empresa,@sp_planta,@sp_mes_proceso,@sp_ano_proceso,@sp_nro_trabajador,
							@sp_dv_trabajador,@sp_tipo_proceso,@cantidad,@moneda,@descuento_grabo,
         					@fec_ini_info,@fec_fin_info,@valor_retorno output

   	select 	@retorno = round( @valor_retorno, 20 )
	select 	@retorno_no_prop = round( @valor_retorno, 20 )
	return 0	
  end

if @rutina_l = 'reliquida_impuesto'
  begin
    exec spliq_reliq_impue @sp_mes_proceso, @sp_ano_proceso,@sp_empresa, @sp_planta,
    @sp_nro_trabajador,@sp_dv_trabajador,@sp_tipo_proceso,@descuento_grabo,@cantidad,
    @moneda,@valor_retorno output
    select @retorno         = round(@valor_retorno,20)
    select @retorno_no_prop = round(@valor_retorno,20)
    return 0
  end
if @rutina_l = 'calc_ext_01'
  begin
    exec calc_ext_01 @sp_empresa, @sp_planta,@sp_mes_proceso, @sp_ano_proceso,@sp_nro_trabajador,
    @sp_dv_trabajador,@sp_tipo_proceso,@cantidad, @moneda,@proporcion_dias_trab,
    @descuento_grabo,@fec_ini_info,@fec_fin_info,@cantidad_tope,@moneda_tope,
    @valor_retorno output,@retorno_no_prop output
    select @retorno = round(@valor_retorno,20)
    select @retorno_no_prop = round(@retorno_no_prop,20)
    return 0
  end
if @rutina_l = 'calc_ext_02'
  begin
    exec calc_ext_02 @sp_empresa, @sp_planta,@sp_mes_proceso, @sp_ano_proceso,@sp_nro_trabajador,
    @sp_dv_trabajador,@sp_tipo_proceso,@cantidad, @moneda,@proporcion_dias_trab,
    @descuento_grabo,@fec_ini_info,@fec_fin_info,@cantidad_tope,@moneda_tope,
    @valor_retorno output,@retorno_no_prop output
    select @retorno = round(@valor_retorno,20)
    select @retorno_no_prop = round(@retorno_no_prop,20)
    return 0
  end
if @rutina_l = 'valdia_vac'
  begin
    exec valdia_vac @sp_empresa, @sp_planta,@sp_mes_proceso, @sp_ano_proceso,@sp_nro_trabajador,
    @sp_dv_trabajador,@sp_tipo_proceso,@cantidad, @moneda,@proporcion_dias_trab,
    @descuento_grabo,@fec_ini_info,@fec_fin_info,@cantidad_tope,@moneda_tope,
    @valor_retorno output,@retorno_no_prop output
    select @retorno = round(@valor_retorno,20)
    select @retorno_no_prop = round(@retorno_no_prop,20)
    return 0
  end
if @rutina_l = 'sc_bonoprom'
begin
    exec sc_proc001 @sp_empresa,@sp_planta,@sp_mes_proceso,@sp_ano_proceso,@sp_nro_trabajador,
         @sp_dv_trabajador,@sp_tipo_proceso,@cantidad,@moneda,@descuento_grabo,
         @fec_ini_info,@fec_fin_info,@valor_retorno output,@retorno_no_prop output
   select @retorno = round(@valor_retorno,20)
   select @retorno_no_prop = round(@retorno_no_prop,20)
return 0
end
if @rutina_l = 'sp_calc_liq_conv'
  begin
    exec sp_calc_liq_conv 
    @sp_nro_trabajador,
    @sp_dv_trabajador, 
    @sp_empresa,
    @sp_planta,
    @sp_mes_proceso,
    @sp_ano_proceso,
    @fec_fin_info, 
    @descuento_grabo,
    @valor_retorno output
    select @retorno = round(@valor_retorno,20)
    return 0
  end  

if @rutina_l = 'sp_gross_glenc'
  begin
    exec sp_gross_glenc 
    @sp_nro_trabajador,
    @sp_dv_trabajador, 
    @sp_empresa,
    @sp_planta,
    @sp_mes_proceso,
    @sp_ano_proceso,
    @fec_fin_info, 
    @descuento_grabo,
    @valor_retorno output
    select @retorno = round(@valor_retorno,20)
    return 0
  end  

  if @rutina_l = 'ernst_subs_lice'
  begin
    exec ernst_subs_lice @sp_empresa, @sp_planta,@sp_mes_proceso, @sp_ano_proceso,@sp_nro_trabajador,
    @sp_dv_trabajador,@sp_tipo_proceso,@cantidad, @moneda,@proporcion_dias_trab,
    @descuento_grabo,@fec_ini_info,@fec_fin_info,@cantidad_tope,@moneda_tope,
    @valor_retorno output,@retorno_no_prop output
    select @retorno = round(@valor_retorno,20)
    select @retorno_no_prop = round(@retorno_no_prop,20)
    return 0
  end
  
  if @rutina_l ='sp_tricot_rtavar'
  begin
    exec sp_tricot_rtavar @sp_empresa, @sp_planta,@sp_mes_proceso, @sp_ano_proceso,@sp_nro_trabajador,
    @sp_dv_trabajador,@sp_tipo_proceso,@cantidad, @moneda,@proporcion_dias_trab,
    @descuento_grabo,@fec_ini_info,@fec_fin_info,@cantidad_tope,@moneda_tope,
    @valor_retorno output,@retorno_no_prop output
    select @retorno = round(@valor_retorno,20)
    select @retorno_no_prop = round(@retorno_no_prop,20)
    return 0
  end

select @retorno = round(@cantidad,20)
select @retorno_no_prop = round(@cantidad,20)
return




GO

