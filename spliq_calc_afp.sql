
/****** Object:  StoredProcedure [dbo].[spliq_calc_afp]    Script Date: 12/02/2018 15:09:35 ******/
DROP PROCEDURE [dbo].[spliq_calc_afp]
GO

/****** Object:  StoredProcedure [dbo].[spliq_calc_afp]    Script Date: 12/02/2018 15:09:35 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO




CREATE PROCEDURE [dbo].[spliq_calc_afp]  
(@sp_mes_proceso int, @sp_ano_proceso int,@sp_empresa int, @sp_planta int,  
 @sp_nro_trabajador int, @sp_dv_trabajador char(1), @sp_tipo_proceso char(4), @sp_flg_revisa_hist char(1))  
as  
declare @sp_ini_informacio datetime,  
@sp_fin_informacio datetime,  
@sp_nombre  char(50),  
@sp_cod_tipo_trabaj char(2),  
@sp_condic_previsio char(1),  
@sp_cod_tipo_jubila char(1),  
@sp_exento_seguro char(1),  
@sp_exento_fondo char(1),  
@sp_mto_cotiz_volun numeric(28,10),  
@sp_mto_dcto_cta_ah numeric(28,10),  
@sp_mto_cotiz_volu2 numeric(28,10),  
@sp_monto_apv_impuestos_prev  numeric(28,10),  
@sp_tot_apv_topado  numeric(28,10),  
@sp_tot_impon_calc numeric(28,10),  
@sp_flg_aporte_sis char(1),  
@sp_flg_contrac_sis char(1),  
@sp_unid_cob_mto_vo char(4),  
@sp_unid_cobro_cta char(4),  
@sp_unid_cob_mto_v2 char(4),  
@sp_cod_centro_cost int,  
@sp_cod_sucursal int,  
@sp_I900 int,  
@sp_cod_afp int,  
@sp_uf_anterior numeric(28,10),  
@sp_mto_tope_prev_uf numeric(28,10),  
@sp_tope_salud_peso numeric(28,10),  
@sp_cod_isapre int,  
@sp_tot_imponible numeric(28,10),  
@sp_ingreso_minimo numeric(28,10),  
@sp_monto_afp_I900 int,  
@sp_monto_inp_I900 int,  
@sp_mto_cancela_pre int,  
@sp_ano_inicial int,  
@sp_mes_inicial int,  
@codigo_busco_l char(10),  
@sp_fec_ini_contr_vige datetime, @sp_fec_fin_contr_vige datetime,  
@sp_tot_impon_stg numeric(28,10),  
@sp_dias_proporcional numeric(28,10),  
@sp_afecto_cotizac numeric(28,10),  
@sp_nAfecImpo   numeric(28,10),  
@sp_val_leyes_socia int,  
@sp_mto_prev_volunt int,  
@sp_mto_ahorro_volu int,  
@sp_tot_dctos_no_le int,  
@monto_calculo numeric(28,10),  
@afecto_cotiz_encontrado numeric(28,10),  
@nPrevVol int,  
@nPrevVol2 int,  
@pje_cotiz_previs_l numeric(28,10),  
@pje_ex_seg_inval_l numeric(28,10),  
@pje_cot_trab_activo numeric(28,10),  
@pje_aporte_trab_activo numeric(28,10),  
@pje_cot_trab_jubil numeric(28,10),  
@pje_aporte_trab_jubil numeric(28,10),  
@haber_aporte_sis int,  
@monto_aporte_sis numeric(28,10),  
@nPorcAplica numeric(28,10),  
@nPorcAplicaSis numeric(28,10),  
@vporsale numeric(28,10),  
@sigla_afp_l char(20),  
@valor_decimal numeric(28,10),  
@nValTopeP numeric(28,10),  
@sp_fecha_nacimiento datetime,  
@sp_cod_sexo char(1),  
@dif_fecha numeric(10,3),  
@sp_nro_dias_enfermo int,  
@valor_contractual_mes numeric(28,10),  
@valor_contractual_mes_topado numeric(28,10),  
@val_afecto_cotiza_afp numeric(28,10),  
@val_afecto_cotiza_inp numeric(28,10),  
@tot_impon_otros numeric(28,10),  
@monto_tope numeric(28,10),
@sp_flg_difer_tope char(1),
@sp_prop_tope_imp_prev char(1),
@sp_rut_trabajador int  
declare  @sp_tot_impon_sin_tope numeric(28,10),  
@sp_nro_dias_asisti numeric(28,10),@nro_dias_enfermo numeric(28,10),  
@sp_nro_dias_vacacione numeric(28,10)  
declare @afecto_llss_lic char(1), @max_afecto_afp numeric(28,10), @sp_sub_trab_joven char(1),  
@sp_ausente_contrato_i int, @sp_ausente_contrato_f int, @sp_dias_prop decimal(13,12)  
declare @SISDiasTrab numeric(28,10), @SISDiasLM numeric (28,10), @ValDiarioLM numeric (28,10)  
declare @RentaImpLM numeric (28,10), @SISTotalLM numeric (28,10)  
declare @tot_impon_calc_SIS numeric (28,10),@sp_nro_dias_ausente int, @afecto_mto_sis_ant numeric (28,10)  
declare @ultimo_imponible numeric (28,10), @monto_impon_seguro numeric (28,10)  
declare @rut_trabajador int, @cont int, @dias_ausente int  
declare @difer_tot_imp numeric (28,10)  
declare @monto_calculo_sis numeric(28,10)  
declare @ex_sis int  
declare @ultimo_imponible_tope numeric(28,10)
declare @flg_no_reb_jub char(1)  
declare @mto_pactado_afp numeric(28,10)
declare @afecto_mutual numeric(28,10),
@afecto_mutu_otros  numeric(28,15),
@usar_dias_hist char(1),
@ano_anterior int, @mes_anterior int,
@nro_lic_ant int,
@desc_haber char(30)

select @valor_contractual_mes_topado = 0  
select @afecto_cotiz_encontrado = 0  
select @sp_ausente_contrato_i = 0  
select @sp_ausente_contrato_f = 0  
select @sp_tot_impon_stg = 0  
select @sp_afecto_cotizac = 0  
select @sp_mto_cancela_pre = 0  
select @sp_val_leyes_socia = 0  
select @sp_mto_prev_volunt = 0  
select @sp_tot_dctos_no_le = 0  
select @sp_mto_ahorro_volu = 0  
select @tot_impon_otros = 0  
select @monto_tope = 0  
select @pje_cot_trab_activo = 0  
select @pje_aporte_trab_activo = 0  
select @pje_cot_trab_jubil = 0  
select @pje_aporte_trab_jubil =0   
select @haber_aporte_sis = 0  
select @monto_aporte_sis = 0  
select @nPorcAplicaSis = 0  select @nPorcAplica = 0  
select @difer_tot_imp = 0  
select @monto_calculo_sis = 0  
select @ex_sis = 1
select @tot_impon_calc_SIS=0
select @afecto_mutual = 0

   
exec spliq_calc_afecto_cot @sp_mes_proceso,@sp_ano_proceso,@sp_empresa,@sp_planta,@sp_nro_trabajador,  
                           @sp_dv_trabajador,@sp_tipo_proceso,@val_afecto_cotiza_afp output,  
                           @val_afecto_cotiza_inp output  
  
----print     '00) spliq_calc_afp - @@val_afecto_cotiza_afp = ' + convert(varchar(100), @val_afecto_cotiza_afp)
----print     '00) spliq_calc_afp - @val_afecto_cotiza_inp = ' + convert(varchar(100), @val_afecto_cotiza_inp)


select @afecto_mutual = @val_afecto_cotiza_afp
  
Select @sp_cod_afp=cod_instit_previsi, @sp_tot_imponible=tot_imponible,  
       @sp_cod_centro_cost=cod_centro_costo, @sp_tot_impon_stg=total_imponi_ley,  
     @sp_mto_cancela_pre=mto_cancela_previs, @sp_val_leyes_socia=val_leyes_sociales,  
     @sp_mto_ahorro_volu=mto_ahorro_volunta, @sp_tot_dctos_no_le=tot_dctos_no_legal,  
     @sp_afecto_cotizac=afecto_cotizacion, @sp_cod_tipo_trabaj=cod_tipo_trabajado,  
     @sp_cod_sucursal=cod_sucursal, @sp_nro_dias_enfermo = nro_dias_enfermo,  
     @sp_tot_impon_sin_tope=tot_impon_sin_tope,  
     @sp_nro_dias_asisti=nro_dias_asistidos,@nro_dias_enfermo=nro_dias_enfermo,  
     @sp_nro_dias_vacacione=nro_dias_vacacione,  
     @max_afecto_afp=max_afecto_cotiz,@sp_fec_ini_contr_vige = fec_ini_contr_vige,  
     @sp_fec_fin_contr_vige=fec_fin_contr,@sp_nro_dias_ausente = nro_dias_ausente,  
     @monto_impon_seguro=monto_impon_seguro  
From historico_liquidac  
where cod_empresa = @sp_empresa and cod_planta = @sp_planta and  
     nro_trabajador =  @sp_nro_trabajador and dv_trabajador = @sp_dv_trabajador and  
     mes_periodo = @sp_mes_proceso And ano_periodo = @sp_ano_proceso And  
     cod_tipo_proceso = @sp_tipo_proceso  
    
----print     'spliq_calc_afp'  
----print     @sp_afecto_cotizac
----print     @sp_tot_impon_sin_tope

	
if @sp_tot_imponible is null  
  select @sp_tot_imponible = 0  
if @sp_tot_impon_stg is null  
  select @sp_tot_impon_stg = 0  
if @sp_mto_cancela_pre is null  
  select @sp_mto_cancela_pre = 0  
if @sp_val_leyes_socia is null  select @sp_val_leyes_socia= 0  
if @sp_mto_ahorro_volu is null  
  select @sp_mto_ahorro_volu= 0  
if @sp_tot_dctos_no_le is null  select @sp_tot_dctos_no_le = 0  
if @sp_afecto_cotizac is null  
   select @sp_afecto_cotizac = 0  
  
  
select @sp_flg_aporte_sis     = flg_aporte_sis,  
       @sp_flg_contrac_sis    = flg_contrac_sis,  
       @sp_flg_difer_tope     = flg_difer_tope,  
       @sp_prop_tope_imp_prev = prop_tope_imp_prev  
from control_parametros  
where cod_empresa = @sp_empresa and cod_planta = @sp_planta and  
mes_control_proces = @sp_mes_proceso and ano_control_proces = @sp_ano_proceso  
  
if @sp_flg_aporte_sis is null or @sp_flg_aporte_sis = ' '  
  select @sp_flg_aporte_sis = 'N'  
if @sp_flg_contrac_sis is null or @sp_flg_contrac_sis = ' '  
  select @sp_flg_contrac_sis = 'N'  
if @sp_flg_difer_tope     is null or @sp_flg_difer_tope = ' '   
  select @sp_flg_difer_tope = 'N'  
if @sp_prop_tope_imp_prev is null or @sp_prop_tope_imp_prev = ' '   
  select @sp_prop_tope_imp_prev = 'N'  
  
select   
@sp_nombre             = nombre,   
@sp_nAfecImpo          = afecto_imponible,  
@sp_monto_afp_I900     = monto_afp_i900,   
@sp_I900               = licencia,   
@sp_ini_informacio     = fec_inicio,  
@sp_fin_informacio     = fec_final,   
@sp_monto_inp_I900     = monto_inp_I900 ,  
@sp_uf_anterior        = uf_anterior,   
@sp_dias_proporcional  = dias_proporcional,  
@sp_ausente_contrato_i = ausente_contrato_i,   
@sp_ausente_contrato_f = ausente_contrato_f  
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
@sp_condic_previsio  =  condic_previsional,   
@sp_cod_tipo_jubila  =  cod_tipo_jubilacio,  
@sp_exento_seguro    =  exento_seguro,   
@sp_exento_fondo     =  exento_fondo,  
@sp_mto_cotiz_volun  =  mto_cotiz_voluntar,   
@sp_unid_cob_mto_vo  =  unid_cob_mto_volun,  
@sp_mto_cotiz_volu2  =  mto_cotiz_volunt_2,   
@sp_unid_cob_mto_v2  =  unid_cob_mto_volu2,  
@sp_mto_dcto_cta_ah  =  mto_dcto_cta_ahorr,   
@sp_unid_cobro_cta   =  unid_cobro_cta_aho,  
@sp_fecha_nacimiento =  fec_nacimiento,  
@sp_cod_sexo         =  cod_sexo,   
@sp_cod_isapre       =  cod_isapre,  
@sp_sub_trab_joven   =  flg_trab_joven,   
@flg_no_reb_jub      =  flg_no_reb_jub,  
@mto_pactado_afp = mto_pactado_afp,
@rut_trabajador=rut_trabajador 
from personal  
where   
cod_empresa    = @sp_empresa        and   
cod_planta     = @sp_planta         and  
nro_trabajador = @sp_nro_trabajador and   
dv_trabajador  = @sp_dv_trabajador  
  
   
 if @flg_no_reb_jub is null or @flg_no_reb_jub = '' or @flg_no_reb_jub = ' '  
  select @flg_no_reb_jub = 'N'  
if @sp_sub_trab_joven = 'S'  
  select @sp_flg_aporte_sis = 'N'  
if @sp_exento_seguro is null or @sp_exento_seguro = ' '  
  select @sp_exento_seguro = 'N'  
if @sp_exento_fondo is null or @sp_exento_fondo = ' '  
  select @sp_exento_fondo = 'N'  
  
if @sp_flg_aporte_sis = 'S'  
  begin  
    select @haber_aporte_sis = cod_haber,
	@desc_haber=descripcion
	from haber   
    where cod_empresa = @sp_empresa and cod_planta = @sp_planta and tipo_hab_contabili = 'H'  
    if @haber_aporte_sis is null select @haber_aporte_sis = 0  
  end  
  
if @sp_mto_cotiz_volun is null   select @sp_mto_cotiz_volun = 0  
if @sp_mto_cotiz_volu2 is null   select @sp_mto_cotiz_volu2 = 0  
if @sp_mto_dcto_cta_ah is null   select @sp_mto_dcto_cta_ah = 0  
if @sp_unid_cob_mto_vo is null   select @sp_unid_cob_mto_vo = ''  
if @sp_unid_cob_mto_v2 is null   select @sp_unid_cob_mto_v2 = ''  
if @sp_sub_trab_joven  is null   select @sp_sub_trab_joven = 'N'  
  
select @monto_calculo = 0  
select @valor_decimal = 0  
select @nValTopeP = 0  
select @nPorcAplica = 0  
select @vporsale = 0  
select @nPorcAplicaSis = 0  
  
select @valor_contractual_mes = sum(isnull(valor_transac_peso,0))  
from haberes_contractua, haber  
where        
haberes_contractua.cod_empresa=haber.cod_empresa and  
haberes_contractua.cod_planta=haber.cod_planta and  
haberes_contractua.cod_haber=haber.cod_haber and  
haberes_contractua.cod_empresa=@sp_empresa and  
haberes_contractua.cod_planta=@sp_planta and  
haberes_contractua.nro_trabajador=@sp_nro_trabajador and  
haberes_contractua.dv_trabajador=@sp_dv_trabajador and  
haberes_contractua.ano_periodo=@sp_ano_proceso and  
haberes_contractua.mes_periodo=@sp_mes_proceso and  
haber.flg_complem_subs ='S'  
   
   
if @valor_contractual_mes is null select @valor_contractual_mes = 0  
  
if @valor_contractual_mes > @sp_tot_imponible  
  select @valor_contractual_mes_topado = @sp_tot_imponible  
else  
  select @valor_contractual_mes_topado = @valor_contractual_mes  

select @dif_fecha=datediff(dd,@sp_fecha_nacimiento,@sp_fin_informacio) / 365.25  
  


if ( ( @dif_fecha >= 59.999 and @sp_cod_sexo = 'F' ) OR ( @dif_fecha >= 64.999 and @sp_cod_sexo = 'M' ) ) and @flg_no_reb_jub = 'N' 
 begin  
		select @monto_calculo_sis = @val_afecto_cotiza_afp  
		select @ex_sis = 0  
	--	if @sp_exento_fondo = 'S'
	--			select @val_afecto_cotiza_afp = 0  
 end  

  
 
select @monto_calculo = @val_afecto_cotiza_afp     
select @sp_tot_impon_calc =   @monto_calculo
     


select @afecto_llss_lic = afecto_llss_lic,
@usar_dias_hist=usar_dias_hist  
from param_licencia  
where  
cod_empresa = @sp_empresa and  
cod_planta  = @sp_planta   
  
if @afecto_llss_lic is null select @afecto_llss_lic = 'N' 
if @usar_dias_hist is null select @usar_dias_hist = 'S'

if @nro_dias_enfermo > 0
if @usar_dias_hist = 'N'
	begin
		select @mes_anterior=datepart(mm,fec_desde_licencia),
		@ano_anterior=datepart(yy, fec_hasta_licencia),
		@nro_lic_ant=isnull(licencia.licencia_anterior,0)
		from licencia right join
		movimiento_ausenci on
		licencia.nro_licencia=  movimiento_ausenci.nro_licencia
		and licencia.licencia_anterior is null
		and licencia.nro_trabajador=  movimiento_ausenci.nro_trabajador
		and licencia.dv_trabajador=  movimiento_ausenci.dv_trabajador
		and licencia.cod_empresa=  movimiento_ausenci.cod_empresa
		and licencia.cod_planta=  movimiento_ausenci.cod_planta
		where movimiento_ausenci.nro_trabajador=@sp_nro_trabajador
		and movimiento_ausenci.dv_trabajador=@sp_dv_trabajador
		and movimiento_ausenci.cod_empresa=@sp_empresa
		and movimiento_ausenci.cod_planta=@sp_planta
		and datepart(mm,movimiento_ausenci.fec_ini_ausencia)=@sp_mes_proceso
		and datepart(yyyy,movimiento_ausenci.fec_ini_ausencia)=@sp_ano_proceso
		
		if @nro_lic_ant!=0
			begin
				select @mes_anterior=@sp_mes_proceso
				select @ano_anterior=@sp_ano_proceso
			end
			
	end

----print     '01) spliq_calc_afp - @afecto_llss_lic = ' + convert(varchar(100), @afecto_llss_lic)
----print     '02) spliq_calc_afp - @sp_nro_dias_enfermo = ' + convert(varchar(100), @sp_nro_dias_enfermo)
----print     '03) spliq_calc_afp - @sp_flg_difer_tope = ' + convert(varchar(100), @sp_flg_difer_tope)
----print     '04) spliq_calc_afp - @ex_sis = ' + convert(varchar(100), @ex_sis)
----print     '05) spliq_calc_afp - @monto_calculo = ' + convert(varchar(100), @monto_calculo)
----print     '06) spliq_calc_afp - @val_afecto_cotiza_afp = ' + convert(varchar(100), @val_afecto_cotiza_afp)
----print     '07) spliq_calc_afp - @sp_tot_imponible = ' + convert(varchar(100), @sp_tot_imponible)
	

   
if @afecto_llss_lic = 'N' and @sp_nro_dias_enfermo >= 30  
	begin
----print     'opcion 0'
	select @monto_calculo = 0  
	end
else if @sp_flg_difer_tope = 'N' and @ex_sis = 1  -- OR @sp_nro_dias_enfermo >= 30)
	begin  
----print     'opcion 1'
		select @valor_contractual_mes = sum(isnull(valor_transac_peso,0))  
		from haberes_contractua  
		where  
		cod_empresa=@sp_empresa and  
		cod_planta=@sp_planta and  
		cod_tipo_proceso=@sp_tipo_proceso and   
		ano_periodo=@sp_ano_proceso and  
		mes_periodo=@sp_mes_proceso and  
		nro_trabajador=@sp_nro_trabajador and  
		dv_trabajador=@sp_dv_trabajador and  
		cod_haber in (select cod_haber from haber where cod_empresa=@sp_empresa and  
		cod_planta=@sp_planta and concepto_imponible='S')  
		
----print     '8a) spliq_calc_afp - @valor_contractual_mes = ' + convert(varchar(100), @valor_contractual_mes)

		if @valor_contractual_mes is null or @valor_contractual_mes< 0
			 select @valor_contractual_mes = 0  
		
		select @valor_contractual_mes = round(@valor_contractual_mes,0)  

----print     '8) spliq_calc_afp - @valor_contractual_mes = ' + convert(varchar(100), @valor_contractual_mes)
----print     '9) spliq_calc_afp - @sp_tot_imponible = ' + convert(varchar(100), @sp_tot_imponible)
----print     '10) spliq_calc_afp - @sp_tot_impon_sin_tope = ' + convert(varchar(100), @sp_tot_impon_sin_tope)

		if @valor_contractual_mes > @sp_tot_imponible  
			if @sp_nro_dias_enfermo > 0   
				begin  
					select top 1 @ultimo_imponible = val_tot_tope_impon,
					 @ultimo_imponible_tope = tot_imponible  
					from historico_liquidac  
					where   
					cod_empresa      = @sp_empresa and  
					cod_planta       = @sp_planta and  
					cod_tipo_proceso = @sp_tipo_proceso and  
					ano_periodo * 100 + mes_periodo < @sp_ano_proceso * 100 + @sp_mes_proceso and   
					nro_trabajador   = @sp_nro_trabajador and  
					dv_trabajador    = @sp_dv_trabajador and  
					nro_dias_enfermo = 0  
					order by ano_periodo desc, mes_periodo desc  

----print     '11) spliq_calc_afp - @ultimo_imponible = ' + convert(varchar(100), @ultimo_imponible)
----print     '11) spliq_calc_afp - @ultimo_imponible_tope = ' + convert(varchar(100), @ultimo_imponible_tope)

		if @sp_flg_difer_tope = 'S'  
			if @sp_tot_imponible > @ultimo_imponible  
				select @difer_tot_imp = ((@sp_tot_imponible - @ultimo_imponible)/30)*@sp_nro_dias_enfermo  
			else    
				select @difer_tot_imp = ((@ultimo_imponible - @sp_tot_imponible)/30)*@sp_nro_dias_enfermo  
		

----print     '12) spliq_calc_afp - @difer_tot_imp = ' + convert(varchar(100), @difer_tot_imp)

		
		if @afecto_llss_lic = 'S' and @sp_nro_dias_enfermo >= 30  
			if round(@sp_tot_impon_sin_tope,0) > @sp_tot_imponible  
				select @monto_calculo = @sp_tot_imponible  
			else  
				select @monto_calculo = round(@sp_tot_impon_sin_tope,0)  
			end  
	else  
		begin  
		if @sp_tot_impon_sin_tope > @sp_tot_imponible  
			select @monto_calculo = round(@sp_tot_imponible,0)  
		else  
			select @monto_calculo = round(@sp_tot_impon_sin_tope,0)  
		end  
else   
	begin  
----print     ' 2 pase aqui???'
		select @monto_calculo = round(@sp_tot_impon_sin_tope,0)  
	end  
end  

		if @sp_flg_difer_tope = 'N' and  @sp_nro_dias_enfermo >= 30  
		begin
			if ((@sp_tot_impon_sin_tope + @ultimo_imponible) >= @sp_tot_imponible
			and @valor_contractual_mes >= @sp_tot_imponible
			and @monto_calculo > 0
			and @ultimo_imponible < @ultimo_imponible_tope)
			begin
----print    'caso1'
				select @monto_calculo = ((@sp_tot_imponible-@ultimo_imponible )/30)*@sp_nro_dias_enfermo  
				select @val_afecto_cotiza_afp = @monto_calculo
			end
			if ((@sp_tot_impon_sin_tope + @ultimo_imponible) >= @sp_tot_imponible
			and @valor_contractual_mes >= @sp_tot_imponible
			--and @monto_calculo > 0
			and @ultimo_imponible >= @ultimo_imponible_tope
			)
			begin
----print    'caso2'
				select @monto_calculo = 0
				select @val_afecto_cotiza_afp = @monto_calculo
				end
----print     '1a)spliq_calc_afp - @monto_calculo = ' + convert(varchar(100), @monto_calculo)

		end

  
-- REVISA VALORES DE OTROS PROCESOS  
-- E : revisa por empresa-planta  
-- C : revisa consolidado por empresa  
-- P : revisa consolidad por base de datos  
  

  
----print     '1b)spliq_calc_afp - @sp_tot_imponible = ' + convert(varchar(100), @sp_tot_imponible)
----print     '1b)spliq_calc_afp - @monto_calculo = ' + convert(varchar(100), @monto_calculo)
----print     '1b)spliq_calc_afp - @sp_flg_revisa_hist = ' + convert(varchar(100), @sp_flg_revisa_hist)  
if @sp_flg_revisa_hist = 'E' or @sp_flg_revisa_hist = 'C' or @sp_flg_revisa_hist = 'P'  
  begin  
    exec spliq_revisa_his @sp_empresa,@sp_planta,@sp_ano_proceso,  
         @sp_mes_proceso,@sp_nro_trabajador,@sp_dv_trabajador, @sp_tipo_proceso,  
         @sp_flg_revisa_hist, @tot_impon_otros output  
  
----print     '1r)spliq_calc_afp - @monto_calculo = ' + convert(varchar(100), @monto_calculo)
----print     '1r)spliq_calc_afp - @tot_impon_otros = ' + convert(varchar(100), @tot_impon_otros)  
----print     '1r)spliq_calc_afp - @sp_monto_afp_I900 = ' + convert(varchar(100), @sp_monto_afp_I900)    
----print     '1r)spliq_calc_afp - @monto_tope = ' + convert(varchar(100), @monto_tope)  
----print   '1r)spliq_calc_afp - @sp_I900 = ' + convert(varchar(100), @sp_I900)  
    
    if @tot_impon_otros > 0  
      begin  
        if @sp_I900 = 1 and @monto_calculo = 0
          select @monto_tope = @sp_monto_afp_I900  
        else  
          select @monto_tope = @sp_tot_imponible  
        if @tot_impon_otros > @monto_tope  
          begin  
            select @monto_calculo = 0  
          end  
        else  
          begin  
            if ( @tot_impon_otros + @monto_calculo) > @monto_tope  
              begin  
                select @monto_calculo = @monto_tope - @tot_impon_otros  
              end  
          end  
      end  
  end  
  
  
  
select @sp_tot_impon_stg  = @monto_calculo  
select @sp_afecto_cotizac = @monto_calculo  
select @afecto_mutual = @monto_calculo  

if @mto_pactado_afp > 0
begin
		select @monto_calculo = @monto_calculo * ((@mto_pactado_afp/100))
end

  
SELECT @pje_cotiz_previs_l     = pje_cotiz_previsio,  
       @pje_ex_seg_inval_l     = pje_ex_seg_invalid,  
       @sigla_afp_l            = sigla_afp,  
       @pje_cot_trab_activo    = pje_aporte_trab_a,  
       @pje_aporte_trab_activo = pje_aporte_emp_a,  
       @pje_cot_trab_jubil     = pje_aporte_trab_j, 
	   @pje_aporte_trab_jubil  = pje_aporte_emp_j  
from afp   
where   
cod_afp = @sp_cod_afp  
  
----print     '1) spliq_calc_afp - @sp_cod_afp = ' + convert(varchar(100), @sp_cod_afp)
	
	
if ( ( @dif_fecha > 59.999 and @dif_fecha <= 65 and @sp_cod_sexo = 'F' ) ) and @flg_no_reb_jub = 'N' and @sp_condic_previsio !='J'  
 select @sp_tot_impon_calc = @monto_calculo_sis  
else  
 select @sp_tot_impon_calc = @monto_calculo  
  
-- Se inicia variable
set @ultimo_imponible_tope = 0
  
--Determinaci½n de afecto para aporte_sis  
if @nro_dias_enfermo > 0  
  begin  
----print     'por aqui????'
    select  @sp_tot_impon_calc = 0  
   
	  
	if @usar_dias_hist = 'S'
	begin  
    select top 1 @sp_tot_impon_calc = afecto_cotizacion,  
                 @sp_ano_inicial = ano_periodo,  
                 @sp_mes_inicial = mes_periodo,  
                 @afecto_mto_sis_ant = afecto_mto_sis,  
                 @ultimo_imponible = val_tot_tope_impon , 
                 @ultimo_imponible_tope = tot_imponible 
    from historico_liquidac  
    where   
    cod_empresa      = @sp_empresa and  
    cod_planta       = @sp_planta and  
    cod_tipo_proceso = @sp_tipo_proceso and  
    ano_periodo * 100 + mes_periodo < @sp_ano_proceso * 100 + @sp_mes_proceso and   
    nro_trabajador   = @sp_nro_trabajador and  
    dv_trabajador    = @sp_dv_trabajador and  
    nro_dias_enfermo = 0  
    order by ano_periodo desc, mes_periodo desc  
    end
	else
	 select top 1 @sp_tot_impon_calc = afecto_cotizacion,  
                 @sp_ano_inicial = ano_periodo,  
                 @sp_mes_inicial = mes_periodo,  
                 @afecto_mto_sis_ant = afecto_mto_sis,  
                 @ultimo_imponible = val_tot_tope_impon , 
                 @ultimo_imponible_tope = tot_imponible 
    from historico_liquidac  
    where   
    cod_empresa      = @sp_empresa and  
    cod_planta       = @sp_planta and  
    cod_tipo_proceso = @sp_tipo_proceso and  
    ano_periodo * 100 + mes_periodo < @ano_anterior * 100 + @mes_anterior and   
    nro_trabajador   = @sp_nro_trabajador and  
    dv_trabajador    = @sp_dv_trabajador and  
    nro_dias_enfermo = 0  
    order by ano_periodo desc, mes_periodo desc  
	
    
----print     '1) spliq_calc_afp - @sp_tot_impon_calc = ' + convert(varchar(100), @sp_tot_impon_calc)
----print     '1) spliq_calc_afp - @afecto_mto_sis_ant = ' + convert(varchar(100), @afecto_mto_sis_ant)
----print     '1) spliq_calc_afp - @ultimo_imponible = ' + convert(varchar(100), @ultimo_imponible)
----print     '1) spliq_calc_afp - @sp_tot_impon_sin_tope = ' + convert(varchar(100), @sp_tot_impon_sin_tope)
----print     '1) spliq_calc_afp - @monto_calculo = ' + convert(varchar(100), @monto_calculo)
    
    
    
    if @sp_tot_impon_calc is null or @sp_tot_impon_calc = 0  
      begin  
        if ( @sp_ano_inicial is null and @sp_mes_inicial is null ) or   
           ( @sp_ano_inicial = 0 and @sp_mes_inicial = 0 )   
          begin   
            select top 1   
            @sp_ano_inicial = ano_periodo,  
            @sp_mes_inicial = mes_periodo  
            from historico_liquidac  
            where   
            cod_empresa        = @sp_empresa and  
            cod_planta         = @sp_planta and  
            cod_tipo_proceso   = @sp_tipo_proceso and  
            ano_periodo * 100  + mes_periodo <= @sp_ano_proceso * 100 + @sp_mes_proceso and   
            nro_trabajador     = @sp_nro_trabajador and  
            dv_trabajador      = @sp_dv_trabajador and  
            fec_ini_contr_vige = @sp_fec_ini_contr_vige  
            order by ano_periodo asc,mes_periodo asc  
          end  
        select  @sp_tot_impon_calc = sum(isnull(valor_transac_peso,0))  
        from haberes_contractua  
        where   
        cod_empresa        = @sp_empresa and  
        cod_planta         = @sp_planta and  
        cod_tipo_proceso   = @sp_tipo_proceso and  
        ano_periodo        = @sp_ano_inicial  and  
     mes_periodo        = @sp_mes_inicial  and  
        nro_trabajador     = @sp_nro_trabajador and  
        dv_trabajador      = @sp_dv_trabajador and  
        cod_haber in (select cod_haber from haber where cod_empresa = @sp_empresa and  
                      cod_planta = @sp_planta and concepto_imponible ='S')  
        
		if @sp_tot_impon_calc is null select @sp_tot_impon_calc = 0  
          select @sp_ingreso_minimo = 0  
        
		exec  spliq_valores_mon @sp_mes_proceso,@sp_ano_proceso,@sp_empresa,@sp_planta,@sp_nro_trabajador,  
              @sp_dv_trabajador,@sp_tipo_proceso, 1,'IMIN',0, @sp_fin_informacio,@codigo_busco_l,'','',  
              @sp_ingreso_minimo output    
        
        
		if @sp_tot_impon_calc = 0 or @sp_tot_impon_calc < @sp_ingreso_minimo  
          select @sp_tot_impon_calc = round(@sp_ingreso_minimo,0)  
        
		select @sp_dias_prop = ( 30 - (@sp_nro_dias_ausente)*1.0  ) / 30 --TIPS 25756  
        
		if @sp_tot_impon_calc > @sp_tot_imponible  
          select @sp_tot_impon_calc = round(@sp_tot_imponible * @sp_dias_prop,0)  
      end   
    else  
      begin  
        if datepart(mm,@sp_fec_ini_contr_vige) = @sp_mes_inicial and  
           datepart(yy,@sp_fec_ini_contr_vige) = @sp_ano_inicial and  
           datepart(dd,@sp_fec_ini_contr_vige) > 1 and @sp_flg_contrac_sis = 'S'  
          begin  
            select  @afecto_cotiz_encontrado = afecto_cotizacion  
            from historico_liquidac  
            where   
            cod_empresa        = @sp_empresa and  
            cod_planta         = @sp_planta and  
            cod_tipo_proceso   = @sp_tipo_proceso and  
            ano_periodo        = @sp_ano_inicial  and  
            mes_periodo        = @sp_mes_inicial  and  
            nro_trabajador     = @sp_nro_trabajador and  
            dv_trabajador      = @sp_dv_trabajador   
            if @afecto_cotiz_encontrado is null select @afecto_cotiz_encontrado = 0  
            select  @sp_tot_impon_calc = sum(isnull(valor_transac_peso,0))  
            from haberes_contractua  
            where   
            cod_empresa        = @sp_empresa and  
            cod_planta         = @sp_planta and  
            cod_tipo_proceso   = @sp_tipo_proceso and  
            ano_periodo        = @sp_ano_inicial  and  
            mes_periodo        = @sp_mes_inicial  and  
            nro_trabajador     = @sp_nro_trabajador and  
            dv_trabajador      = @sp_dv_trabajador and  
            cod_haber in (select cod_haber from haber where cod_empresa = @sp_empresa and  
                        cod_planta = @sp_planta and concepto_imponible ='S')  
            if @sp_tot_impon_calc is null select @sp_tot_impon_calc = 0  
            --if @sp_tot_impon_calc > @afecto_cotiz_encontrado  
            --  select @sp_tot_impon_calc = @afecto_cotiz_encontrado  
            select @sp_ingreso_minimo = 0  
            exec  spliq_valores_mon @sp_mes_proceso,@sp_ano_proceso,@sp_empresa,@sp_planta,@sp_nro_trabajador,  
                  @sp_dv_trabajador,@sp_tipo_proceso, 1,'IMIN',0, @sp_fin_informacio,@codigo_busco_l,'','',  
                  @sp_ingreso_minimo output    
            if @sp_tot_impon_calc = 0 or @sp_tot_impon_calc < @sp_ingreso_minimo  
              select @sp_tot_impon_calc = round(@sp_ingreso_minimo,0)    
          end  
      end    
    select @sp_dias_prop = ( 30 - (@sp_nro_dias_ausente)*1.0  ) / 30 --TIPS 25756  
end    

----print     'afp2.0'
----print     '07) spliq_calc_afp - @sp_tot_imponible = ' + convert(varchar(100), @sp_tot_imponible)
----print     '07) spliq_calc_afp - @ultimo_imponible = ' + convert(varchar(100), @ultimo_imponible)
----print     '07) spliq_calc_afp - @monto_calculo = ' + convert(varchar(100), @monto_calculo)
----print     '07) spliq_calc_afp - @sp_flg_difer_tope = ' + convert(varchar(100), @sp_flg_difer_tope)
----print     '07) spliq_calc_afp - @sp_tot_impon_calc = ' + convert(varchar(100), @sp_tot_impon_calc)
----print     '07) spliq_calc_afp - @sp_tot_impon_sin_tope = ' + convert(varchar(100), @sp_tot_impon_sin_tope)
----print     '07) spliq_calc_afp - @sp_tot_imponible = ' + convert(varchar(100), @sp_tot_imponible)
----print     'afp2.0'
  
  
  
  
  
if @sp_flg_difer_tope = 'N'  
begin  
    if @sp_nro_dias_asisti > 0  
	   begin  
		if @monto_calculo >= @sp_tot_imponible  
			begin  
				if round((@sp_tot_imponible * ( @sp_nro_dias_asisti + @sp_nro_dias_vacacione) ) / 30,0) >= @monto_calculo and @sp_prop_tope_imp_prev = 'S'  
						select @max_afecto_afp = @sp_tot_imponible - @monto_calculo - isnull(round(((@ultimo_imponible/ 30 ) * @nro_dias_enfermo ),0),0)  
				else if round((@sp_tot_imponible * ( @sp_nro_dias_asisti + @sp_nro_dias_vacacione) ) / 30,0) >= @monto_calculo and @sp_prop_tope_imp_prev = 'N'  
						select @max_afecto_afp = @sp_tot_imponible - @monto_calculo  
				else  
						select @max_afecto_afp = 0  
			end  
		else  
			begin  
				if @sp_prop_tope_imp_prev = 'S' and @nro_dias_enfermo = 0  
					begin  
					select @max_afecto_afp = round((@sp_tot_imponible * ( @sp_nro_dias_asisti + @sp_nro_dias_vacacione) ) / 30,0) - @monto_calculo  
					select @max_afecto_afp = @sp_tot_imponible - @monto_calculo -@ultimo_imponible  
					end  
				else if @sp_prop_tope_imp_prev = 'S' and @nro_dias_enfermo > 0  
					select @max_afecto_afp = @sp_tot_imponible - @valor_contractual_mes  
				else if @sp_prop_tope_imp_prev = 'N'  
					select @max_afecto_afp = @sp_tot_imponible - @monto_calculo  
				else  
					select @max_afecto_afp = 0  
		   end  
      end  
    else  
      begin  
        if @afecto_llss_lic = 'N'  
          select @max_afecto_afp = @valor_contractual_mes_topado - @monto_calculo  
        else  
          if @sp_prop_tope_imp_prev = 'S'  
            select @max_afecto_afp = @sp_tot_imponible - @valor_contractual_mes_topado  
          else  
   select @max_afecto_afp = @sp_tot_imponible - @monto_calculo  
      end  
  end  
   
----print     'afp2'  
----print     @max_afecto_afp  
   
   
 --Corrige mÿximos con licencia   
  IF (@sp_afecto_cotizac >= round((@sp_tot_imponible * ( @sp_nro_dias_asisti + @sp_nro_dias_vacacione) ) / 30,0)) and @nro_dias_enfermo > 0 and @sp_flg_difer_tope = 'N'  
 select @max_afecto_afp = 0  
  
  --Corrige mÿximos  
    
----print     'afp3'  
----print     '07) spliq_calc_afp - @max_afecto_afp = ' + convert(varchar(100), @max_afecto_afp)

if @sp_flg_revisa_hist != 'N'
begin 
	select @cont=COUNT(rut_trabajador)   
	from personal where rut_trabajador = @rut_trabajador   
	and cod_vigen_trabajad = 'S'  











If @cont > 1 
	begin  
	if @sp_afecto_cotizac >= @sp_tot_imponible  
	begin  
		select @max_afecto_afp = 0  
	end  
	else  
	begin  
	select @max_afecto_afp = @sp_tot_imponible-@sp_afecto_cotizac-@tot_impon_otros  
	end  
end   

end 
  
----print     'afp4' 
----print     '07) spliq_calc_afp - @@max_afecto_afp = ' + convert(varchar(100), @max_afecto_afp)
----print     '07) spliq_calc_afp - @@monto_calculo = ' + convert(varchar(100), @monto_calculo)
----print     '07) spliq_calc_afp - @@sp_tot_impon_sin_tope = ' + convert(varchar(100), @sp_tot_impon_sin_tope)
----print     '07) spliq_calc_afp - @@sp_tot_impon_stg = ' + convert(varchar(100), @sp_tot_impon_stg)
----print     '07) spliq_calc_afp - @@sp_tot_imponible = ' + convert(varchar(100), @sp_tot_imponible)
 

--if @monto_calculo = 0
--	if @sp_tot_imponible > 0 and @sp_tot_imponible < 
--	select @monto_calculo = @sp_tot_impon_stg  
  
if @max_afecto_afp < 0  
 select @max_afecto_afp = 0  
--  
 select @dif_fecha=datediff(dd,@sp_fecha_nacimiento,@sp_fin_informacio) / 365.25
----print     '1) spliq_calc_afp - @sp_flg_aporte_sis = ' + convert(varchar(100), @sp_flg_aporte_sis) 
----print     '1) spliq_calc_afp - @@sp_condic_previsio = ' + convert(varchar(100), @sp_condic_previsio)   
----print     '1) spliq_calc_afp - @sp_cod_tipo_jubila = ' + convert(varchar(100), @sp_cod_tipo_jubila)   
----print     '1) spliq_calc_afp - @@sp_exento_seguro = ' + convert(varchar(100), @sp_exento_seguro)    
----print     '1) spliq_calc_afp - @sp_exento_fondo = ' + convert(varchar(100), @sp_exento_fondo)   
----print     '1) spliq_calc_afp - @sp_tot_impon_calc = ' + convert(varchar(100), @sp_tot_impon_calc)
 
----print     '1) spliq_calc_afp - @dif_fecha = ' + convert(varchar(100), @dif_fecha)   

----print     'pre SISSS'  
----print     '1) spliq_calc_afp - @monto_aporte_sis = ' + convert(varchar(100), @monto_aporte_sis) 
----print     '2) spliq_calc_afp - @sp_tot_impon_calc = ' + convert(varchar(100), @sp_tot_impon_calc)   


if @sp_condic_previsio != 'J'  
	begin  
		if ( @dif_fecha >= 59.999 and @sp_cod_sexo = 'F') or(@dif_fecha >= 64.999 AND  @sp_cod_sexo = 'M' ) 
			begin  
----print     'J1'
				if  @flg_no_reb_jub = 'N'  
					begin
						select @valor_decimal = 0
						select @nPorcAplica = 0
					end
				else
					begin
						 select @valor_decimal = round((@monto_calculo * ( @pje_cot_trab_activo / 100.00)),0)  
						 select @nPorcAplica = @pje_cot_trab_activo   
					end
				if @sp_flg_aporte_sis = 'S'  AND  @dif_fecha >= 64.999 
				  begin  
						select @monto_aporte_sis = 0
						select @nPorcAplicaSis = 0
						select @monto_calculo = 0  
				  end
				 else if @sp_flg_aporte_sis = 'S'  AND  @dif_fecha <=65
					begin
					  select @monto_aporte_sis = round((@sp_tot_impon_calc * ( @pje_aporte_trab_activo / 100.00)),0)
					  select @nPorcAplicaSis = @pje_aporte_trab_activo  
					 end 
			END
		else if @dif_fecha < 65.000 
			begin
----print     'J2'
				select @valor_decimal = round((@monto_calculo * ( @pje_cot_trab_activo / 100.00)),0)  
				select @nPorcAplica = @pje_cot_trab_activo   
				if @sp_flg_aporte_sis = 'S'
					begin
----print     'J2.1'
						 select @monto_aporte_sis = round((@sp_tot_impon_calc * ( @pje_aporte_trab_activo / 100.00)),0)
						 select @nPorcAplicaSis = @pje_aporte_trab_activo  
					end
			end
     end  
else -- @sp_condic_previsio = 'J'  
	begin
		if @sp_exento_seguro  = 'S' AND @sp_exento_fondo    = 'S'  
			begin
----print     'J1'
				select @monto_aporte_sis = 0
				select @nPorcAplicaSis = 0
				select @valor_decimal = 0
				select @nPorcAplica = 0
			END
		else if @sp_exento_seguro   = 'S' AND @sp_exento_fondo    = 'N'  
			begin
----print     'J2'
				select @valor_decimal = round((@monto_calculo * ( @pje_cot_trab_activo / 100.00)),0)  
				select @nPorcAplica = @pje_cot_trab_activo   
				select @monto_aporte_sis = 0
				select @nPorcAplicaSis = 0
				
			END
		else if @sp_exento_seguro   = 'N' AND @sp_exento_fondo    = 'S'  
			begin
----print     'J3'
				select @valor_decimal = 0
				select @nPorcAplica = 0
				select @monto_aporte_sis = 0
				select @nPorcAplicaSis = 0
			END
	END


  
----print     'SISSS'  
----print     '1) spliq_calc_afp - @monto_aporte_sis = ' + convert(varchar(100), @monto_aporte_sis) 
----print     '2) spliq_calc_afp - @sp_tot_impon_calc = ' + convert(varchar(100), @sp_tot_impon_calc)   
----print     '3) spliq_calc_afp - @nro_dias_enfermo = ' + convert(varchar(100), @nro_dias_enfermo)   
----print     '4) spliq_calc_afp - @sp_tot_impon_stg  = ' + convert(varchar(100), @sp_tot_impon_stg)    
----print     '5) spliq_calc_afp - @sp_tot_imponible  = ' + convert(varchar(100), @sp_tot_imponible)   
----print     '6) spliq_calc_afp - @nPorcAplicaSis = ' + convert(varchar(100), @nPorcAplicaSis)
----print     '7) spliq_calc_afp -  @monto_aporte_sis = ' + convert(varchar(100), @monto_aporte_sis)   
----print     '8) spliq_calc_afp - @sp_tot_impon_sin_tope  = ' + convert(varchar(100), @sp_tot_impon_sin_tope )
----print     '9) spliq_calc_afp -  @tot_impon_calc_SIS  = ' + convert(varchar(100), @tot_impon_calc_SIS)   
----print     '10) spliq_calc_afp - @monto_calculo  = ' + convert(varchar(100), @monto_calculo)
----print     '11) spliq_calc_afp -  @ultimo_imponible = ' + convert(varchar(100), @ultimo_imponible)   
----print     '12) spliq_calc_afp - @ultimo_imponible_tope  = ' + convert(varchar(100), @ultimo_imponible_tope)   
----print     '12) spliq_calc_afp - @sp_tot_impon_calc  = ' + convert(varchar(100), @sp_tot_impon_calc)   
----print     '12) spliq_calc_afp - @usar_dias_hist  = ' + convert(varchar(100), @usar_dias_hist)   

----print     'Siis'

if @monto_aporte_sis > 0  
  begin  
	if @nro_dias_enfermo > 0  
		begin    
		 if @nro_dias_enfermo = DATEPART(day,@sp_fin_informacio) and @sp_mes_proceso = 2  
			set @nro_dias_enfermo = 30  
		end

if @usar_dias_hist = 'N'
	select @tot_impon_calc_SIS = @sp_tot_impon_calc
else
	select @tot_impon_calc_SIS = round((@sp_tot_impon_calc/30*@nro_dias_enfermo),0) 

	select @tot_impon_calc_SIS = @tot_impon_calc_SIS + @sp_tot_impon_sin_tope
	
	if @nro_dias_enfermo = 30  and @sp_mes_proceso = 2  
		select @tot_impon_calc_SIS = round((@sp_tot_impon_calc/30*@nro_dias_enfermo),0)--+@sp_tot_impon_stg --round((@sp_tot_impon_stg/30*(@sp_nro_dias_asisti + @sp_nro_dias_vacacione)),0)
	else
		select @tot_impon_calc_SIS = round((@sp_tot_impon_calc/30*@nro_dias_enfermo),0)+@sp_tot_impon_stg --round((@sp_tot_impon_stg/30*(@sp_nro_dias_asisti + @sp_nro_dias_vacacione)),0)
    
----print     '13) spliq_calc_afp -  @tot_impon_calc_SIS  = ' + convert(varchar(100), @tot_impon_calc_SIS)   
----print     '14) spliq_calc_afp -  @sp_tot_imponible  = ' + convert(varchar(100), @sp_tot_imponible)   
     
     if @tot_impon_calc_SIS > @sp_tot_imponible
   	    select @tot_impon_calc_SIS = @sp_tot_imponible 

     if @sp_flg_difer_tope = 'S'  
     begin
----print     'CALCULO DIFERENCIA'
----print     @tot_impon_calc_SIS
  		
----print     '9b) spliq_calc_afp -  @tot_impon_calc_SIS  = ' + convert(varchar(100), @tot_impon_calc_SIS)				
  		if (@sp_tot_impon_calc > = @sp_tot_imponible) 
  		or (@sp_tot_impon_sin_tope > = @sp_tot_imponible)
  		or (@sp_tot_impon_calc > = @ultimo_imponible_tope)
  		and @ultimo_imponible_tope > 0 and @usar_dias_hist = 'S'
  		begin
----print     '9C) spliq_calc_afp -  @tot_impon_calc_SIS  = ' + convert(varchar(100), @tot_impon_calc_SIS)				
----print     @sp_tot_imponible
----print     @ultimo_imponible_tope
  			
  			select @difer_tot_imp = @sp_tot_imponible-@ultimo_imponible_tope
  			select @difer_tot_imp = (@difer_tot_imp/30)*@nro_dias_enfermo
----print     'CALCULO DIFERENCIA 2'
----print     @tot_impon_calc_SIS
----print     @difer_tot_imp
  			
  			if @sp_flg_difer_tope = 'S'  and @sp_prop_tope_imp_prev = 'S'
  			begin
  				select @tot_impon_calc_SIS = @tot_impon_calc_SIS + @difer_tot_imp
  				select @difer_tot_imp = 0
  			end
  			
  			if @tot_impon_calc_SIS > @sp_tot_imponible
  				select @tot_impon_calc_SIS =  @sp_tot_imponible
  		end
  	
  	end
  	
----print     'antes) spliq_calc_afp - @monto_aporte_sis = ' + convert(varchar(100), @monto_aporte_sis) 
----print     'antes) spliq_calc_afp - @tot_impon_calc_SIS = ' + convert(varchar(100), @tot_impon_calc_SIS) 
----print     'antes) spliq_calc_afp - @nPorcAplicaSis = ' + convert(varchar(100), @nPorcAplicaSis) 
  
  -- If agregado por MLB	
 --if (@sp_flg_revisa_hist != 'C' and @sp_flg_revisa_hist != 'E' and @sp_flg_revisa_hist != 'P')
-- begin
----print     ' If agregado por MLB' 
    select @SISTotalLM=round((@tot_impon_calc_SIS * ( @nPorcAplicaSis / 100.00)),0)  
    select @monto_aporte_sis=@SISTotalLM  -- Aqui est  el problema
---- end
  
----print     'despues) spliq_calc_afp - @monto_aporte_sis = ' + convert(varchar(100), @monto_aporte_sis) 
 
if (@dif_fecha <= 65)   
begin 
--if @mto_pactado_afp > 0
--begin
--		select @monto_aporte_sis = @monto_aporte_sis * ((@mto_pactado_afp/100))
--		select @tot_impon_calc_SIS = @tot_impon_calc_SIS * ((@mto_pactado_afp/100))
--end 
	  exec spliq_haber_indiv @sp_mes_proceso, @sp_ano_proceso, @sp_empresa,@sp_planta,   
		   @sp_nro_trabajador, @sp_dv_trabajador, @sp_tipo_proceso, @haber_aporte_sis,   
		   @nPorcAplicaSis,'%IM',@monto_aporte_sis , @sp_cod_centro_cost,@sp_cod_centro_cost,   
		   @sp_cod_tipo_trabaj ,@sp_cod_sucursal, 1,1, @desc_haber
  end
----print     '1) spliq_calc_afp - @tot_impon_calc_SIS = ' + convert(varchar(100), @tot_impon_calc_SIS) 
----print     '1) spliq_calc_afp - @difer_tot_imp = ' + convert(varchar(100), @difer_tot_imp) 
----print     '1) spliq_calc_afp - @sp_tot_impon_sin_tope = ' + convert(varchar(100), @sp_tot_impon_sin_tope) 
end

/*    
  if @sp_flg_difer_tope = 'N'  
  BEGIN
   if @nro_dias_enfermo < 30  
    IF @sp_tot_impon_sin_tope > @sp_tot_imponible  
     select @tot_impon_calc_SIS = round((@sp_tot_impon_calc/30*@nro_dias_enfermo),0)+round((@sp_tot_imponible/30*(@sp_nro_dias_asisti + @sp_nro_dias_vacacione)),0)  
    else  
     select @tot_impon_calc_SIS = round((@sp_tot_impon_calc/30*@nro_dias_enfermo),0)+ @sp_tot_impon_sin_tope -- round((@sp_tot_impon_sin_tope/30*(@sp_nro_dias_asisti + @sp_nro_dias_vacacione)),0)  
  END
  else  
BEGIN
----print     'ASASASASAS'
   select @tot_impon_calc_SIS = round((@sp_tot_impon_calc/30*@nro_dias_enfermo),0) + @sp_tot_impon_stg --+ round((@sp_tot_impon_stg/30*(@sp_nro_dias_asisti + @sp_nro_dias_vacacione)),0)  
----print     @tot_impon_calc_SIS
   END
  if @sp_mes_proceso = 2 and @nro_dias_enfermo = 30  
   select @tot_impon_calc_SIS = round((@sp_tot_impon_calc/30*(@nro_dias_enfermo-2)),0)+ @sp_tot_impon_sin_tope   
    
  if @tot_impon_calc_SIS > @sp_tot_imponible  
   select @tot_impon_calc_SIS = @sp_tot_imponible  
  select @SISTotalLM=round((@tot_impon_calc_SIS * ( @nPorcAplicaSis / 100.00)),0)  
  select @monto_aporte_sis=@SISTotalLM  
  
    end  
----print     '212232'
----print     @tot_impon_calc_SIS
----print     @monto_aporte_sis
   
 if (@dif_fecha <= 65)   
  exec spliq_haber_indiv @sp_mes_proceso, @sp_ano_proceso, @sp_empresa,@sp_planta,   
  @sp_nro_trabajador, @sp_dv_trabajador, @sp_tipo_proceso, @haber_aporte_sis,   
  @nPorcAplicaSis,'%IM',@monto_aporte_sis , @sp_cod_centro_cost,@sp_cod_centro_cost,   
  @sp_cod_tipo_trabaj ,@sp_cod_sucursal  
  end  
else  
  select @sp_tot_impon_calc = 0  
*/  
----print     'linea 810' 
----print     '07) spliq_calc_afp - @@monto_calculo = ' + convert(varchar(100), @monto_calculo)
----print     '07) spliq_calc_afp - @@@max_afecto_afp = ' + convert(varchar(100), @max_afecto_afp)
----print     '07) spliq_calc_afp - @@@sp_tot_impon_calc = ' + convert(varchar(100), @sp_tot_impon_calc)
----print     '07) spliq_calc_afp - @@@tot_impon_calc_SIS = ' + convert(varchar(100), @tot_impon_calc_SIS)
 



  
if @monto_calculo <= 0 and ( @sp_flg_revisa_hist != 'C' and @sp_flg_revisa_hist != 'E' and @sp_flg_revisa_hist != 'P' ) and @sp_flg_difer_tope = 'N'  
  begin  
----print     'return 1'  
   update historico_liquidac   
   set max_afecto_cotiz = @max_afecto_afp,  
       max_imponi_ley   = @max_afecto_afp,  
       pje_cotiz_previs = @nPorcAplica,  
       pje_aporte_sis   = @nPorcAplicaSis,  
       monto_aporte_sis = @monto_aporte_sis,  
       afecto_mto_sis   = @tot_impon_calc_SIS  
      where cod_empresa = @sp_empresa and cod_planta = @sp_planta and  
            mes_periodo = @sp_mes_proceso and ano_periodo = @sp_ano_proceso And  
            cod_tipo_proceso = @sp_tipo_proceso and  
            nro_trabajador =  @sp_nro_trabajador and dv_trabajador = @sp_dv_trabajador  
  -- return  
  end  
else if @monto_calculo <= 0 and ( @sp_flg_revisa_hist != 'C' and @sp_flg_revisa_hist != 'E' and @sp_flg_revisa_hist != 'P' ) and  @sp_flg_difer_tope = 'S'  
  begin  
----print     'return2 '  
   update historico_liquidac   
   set   
       pje_cotiz_previs = @nPorcAplica,  
       pje_aporte_sis   = @nPorcAplicaSis,  
       monto_aporte_sis = @monto_aporte_sis,  
       afecto_mto_sis   = @tot_impon_calc_SIS  
      where cod_empresa = @sp_empresa and cod_planta = @sp_planta and  
            mes_periodo = @sp_mes_proceso and ano_periodo = @sp_ano_proceso And  
            cod_tipo_proceso = @sp_tipo_proceso and  
            nro_trabajador =  @sp_nro_trabajador and dv_trabajador = @sp_dv_trabajador  
 --return  
 end  
  
  
  
----print     'afp5'  
----print     @max_afecto_afp  
----print     @valor_decimal
----print     @monto_calculo  
----print     @sp_flg_difer_tope
----print     @sp_tot_impon_calc
----print     @sp_mto_cancela_pre
----print     @nPorcAplica
----print     'antes de insertar el 501 '

 
--if @sp_flg_difer_tope = 'N' and @max_afecto_afp = 0 and @nro_dias_enfermo >= 30  
--	select @valor_decimal = 0


select @sp_mto_cancela_pre = round(@valor_decimal, 0)  
if @sp_mto_cancela_pre > 0
exec  spliq_inserta_des @sp_mes_proceso, @sp_ano_proceso, @sp_empresa, @sp_planta,  
                         @sp_nro_trabajador, @sp_dv_trabajador, @sp_tipo_proceso, 501,  
                         @nPorcAplica,'%IM', @sp_mto_cancela_pre , @sp_cod_centro_cost,  
                         @sp_cod_afp, @sigla_afp_l, @sp_cod_centro_cost,  
                         @sp_cod_tipo_trabaj, @sp_cod_sucursal,0,0, '', null


         
  
select @sp_val_leyes_socia = @sp_val_leyes_socia +  @sp_mto_cancela_pre  
select @valor_decimal = 0  
select @nPrevVol = 0  
select @nPrevVol2 = 0  
  
----print     '2) spliq_calc_afp - @sp_val_leyes_socia = ' + convert(varchar(100), @sp_val_leyes_socia)
  
if (@sp_mto_cotiz_volun > 0 AND @sp_unid_cob_mto_vo is not null) OR (@sp_mto_cotiz_volu2 > 0 AND @sp_unid_cob_mto_v2 is not null)  
begin  
----print     'cotiz_volnta'  
----print     @sp_mto_cotiz_volun  
----print     @sp_unid_cob_mto_vo  
   if @sp_mto_cotiz_volun > 0 AND @sp_unid_cob_mto_vo is not null  
   begin  
     if @sp_unid_cob_mto_vo = '$'    
        select @valor_decimal = @sp_mto_cotiz_volun  
     else  
        exec  spliq_valores_mon @sp_mes_proceso, @sp_ano_proceso,@sp_empresa, @sp_planta,  
                           @sp_nro_trabajador, @sp_dv_trabajador, @sp_tipo_proceso,  
                           @sp_mto_cotiz_volun, @sp_unid_cob_mto_vo, 502,  
                           @sp_fin_informacio, '', 'N','N', @valor_decimal output  
     select @nPrevVol = round(@valor_decimal, 0)  
   end  
  
   if @sp_mto_cotiz_volu2 > 0 AND @sp_unid_cob_mto_v2 is not null  
   begin  
     if @sp_unid_cob_mto_v2 = '$'    
        select @valor_decimal = @sp_mto_cotiz_volu2  
     else  
        exec  spliq_valores_mon @sp_mes_proceso, @sp_ano_proceso, @sp_empresa, @sp_planta,  
                           @sp_nro_trabajador, @sp_dv_trabajador, @sp_tipo_proceso,  
                           @sp_mto_cotiz_volu2, @sp_unid_cob_mto_v2, 502,  
                           @sp_fin_informacio, '', 'N','N', @valor_decimal output  
  
     select @nPrevVol2 = round(@valor_decimal, 0)  
   end  
   
   if @nPrevVol2 = 0 AND @nPrevVol = 0  
      INSERT INTO errores_calculo  
             (cod_empresa, cod_planta, nro_trabajador, dv_trabajador,  
              nombre, cod_error_tabla, descripcion_codigo, masivo_informado,  
              descripcion_error, tabla_del_error,cod_tipo_proceso,tipo_error)  
      VALUES (@sp_empresa, @sp_planta, @sp_nro_trabajador, @sp_dv_trabajador,  
              @sp_nombre, 13, 'Revisar montos voluntarios', 'C',  
              'Revisar previsión voluntaria en personal', 'Personal',@sp_tipo_proceso,'E')  
  
   select @sp_mto_prev_volunt = @nPrevVol2 + @nPrevVol  
  
   exec  spliq_inserta_des @sp_mes_proceso, @sp_ano_proceso, @sp_empresa, @sp_planta,  
                            @sp_nro_trabajador, @sp_dv_trabajador, @sp_tipo_proceso,502,  
                            @sp_mto_prev_volunt,'$', @sp_mto_prev_volunt,  
                            @sp_cod_centro_cost,@sp_cod_afp, @sigla_afp_l,  
                            @sp_cod_centro_cost, @sp_cod_tipo_trabaj, @sp_cod_sucursal,0,0, ''  ,null
  
  
   select @nValTopeP = 0  
  
   exec  spliq_valores_mon @sp_mes_proceso, @sp_ano_proceso, @sp_empresa, @sp_planta,  
                           @sp_nro_trabajador, @sp_dv_trabajador, @sp_tipo_proceso,  
                           1, 'TAPV', 502,  
                           @sp_fin_informacio, '', 'N','N', @valor_decimal output  
  
   if @valor_decimal is null  
        select @valor_decimal=0  
  
  
   select @nValTopeP = @valor_decimal  
  
   if @nValTopeP = 0  
   begin  
      exec  spliq_valores_mon @sp_mes_proceso, @sp_ano_proceso, @sp_empresa, @sp_planta,  
                           @sp_nro_trabajador, @sp_dv_trabajador, @sp_tipo_proceso,  
                           50, 'UF', 502,  
                           @sp_fin_informacio, '', 'N','N', @valor_decimal output  
     select @nValTopeP = @valor_decimal  
   end  

   -- volver??
	  -- if round(@sp_mto_prev_volunt,0) > round(@nValTopeP,0)
		 -- begin  
			-- select @sp_val_leyes_socia = @sp_val_leyes_socia + @nValTopeP
		 -- end  
	  -- else  
		 -- begin  
			--select @sp_val_leyes_socia = @sp_val_leyes_socia + @sp_mto_prev_volunt
		 -- end  
    -- volver??? 


   if (@sp_flg_revisa_hist != 'C' and @sp_flg_revisa_hist != 'E' and @sp_flg_revisa_hist != 'P')
   begin
	   if round(@sp_mto_prev_volunt,0) > round(@nValTopeP,0)
		  begin  
			 select @sp_val_leyes_socia = @sp_val_leyes_socia + @nValTopeP
		  end  
	   else  
		  begin  
			select @sp_val_leyes_socia = @sp_val_leyes_socia + @sp_mto_prev_volunt
		  end  
		  
   end
   else
   begin
       select @sp_rut_trabajador = rut_trabajador    
       from   personal    
       where  cod_empresa=@sp_empresa and    
              cod_planta=@sp_planta and    
              nro_trabajador = @sp_nro_trabajador and    
              dv_trabajador = @sp_dv_trabajador    
   
	   if @sp_flg_revisa_hist = 'E'
		   select @sp_monto_apv_impuestos_prev = ISNULL(SUM(a.monto_apv_topado),0)
           from historico_liquidac a, personal b    
           where    
           a.cod_empresa     = @sp_empresa and    
           a.cod_planta      = @sp_planta and    
           a.mes_periodo     = @sp_mes_proceso and    
           a.ano_periodo     = @sp_ano_proceso and    
           a.nro_trabajador != @sp_nro_trabajador and    
           a.cod_tipo_proceso in (select p.cod_tipo_proceso from tipo_proceso p where p.flg_proceso_lq='S') and    
           a.cod_empresa     = b.cod_empresa and    
           a.cod_planta      = b.cod_planta and    
           a.nro_trabajador  = b.nro_trabajador and    
           a.dv_trabajador   = b.dv_trabajador and    
           b.rut_trabajador  = @sp_rut_trabajador    
			
       else if @sp_flg_revisa_hist = 'C'
		   select @sp_monto_apv_impuestos_prev = ISNULL(SUM(a.monto_apv_topado),0)
           from historico_liquidac a, personal b    
           where     
           ( (a.cod_empresa   = @sp_empresa and    
              a.cod_planta       != @sp_planta and    
              a.mes_periodo      = @sp_mes_proceso and    
              a.ano_periodo      = @sp_ano_proceso ) or    
             (a.cod_empresa    = @sp_empresa and    
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
       
       else if @sp_flg_revisa_hist = 'P'  
		   select @sp_monto_apv_impuestos_prev = ISNULL(SUM(a.monto_apv_topado),0)
           from historico_liquidac a, personal b    
           where     
           ( (a.cod_empresa = @sp_empresa and    
              a.cod_planta != @sp_planta ) or    
             (a.cod_empresa = @sp_empresa and    
              a.cod_planta = @sp_planta  and    
              a.nro_trabajador != @sp_nro_trabajador) or    
              a.cod_empresa != @sp_empresa ) and     
           a.cod_tipo_proceso in (select p.cod_tipo_proceso from tipo_proceso p where p.flg_proceso_lq='S') and    
           a.cod_empresa      = b.cod_empresa and    
           a.cod_planta       = b.cod_planta and    
           a.nro_trabajador   = b.nro_trabajador and    
           a.dv_trabajador    = b.dv_trabajador and    
           a.mes_periodo      = @sp_mes_proceso and    
           a.ano_periodo      = @sp_ano_proceso and    
           b.rut_trabajador   = @sp_rut_trabajador    
   		  
----print     '2.3) spliq_calc_afp - @sp_monto_apv_impuestos_prev = ' + convert(varchar(100), round(@sp_monto_apv_impuestos_prev,0))
	   
	   set @sp_tot_apv_topado = @sp_monto_apv_impuestos_prev + @sp_mto_prev_volunt
	   
 	   declare @faltante numeric (28,10)
 	   
	   set @faltante = 0	   
	   if round(@sp_tot_apv_topado,0) > round(@nValTopeP,0)
		  begin  
	      
		  set @faltante = @nValTopeP - @sp_monto_apv_impuestos_prev
----print     '2.4) spliq_calc_afp - @faltante = ' + convert(varchar(100), round(@faltante,0))
		  if (@faltante > 0) 
			 select @sp_val_leyes_socia = @sp_val_leyes_socia + @faltante
		  end  
	   else  
		  begin  
			select @sp_val_leyes_socia = @sp_val_leyes_socia + @sp_mto_prev_volunt
			set @faltante = @sp_mto_prev_volunt
		  end  
		  
----print     '3) spliq_calc_afp - @sp_val_leyes_socia = ' + convert(varchar(100), @sp_val_leyes_socia)
	   
   
   end  


   
   select @sp_tot_dctos_no_le = @sp_tot_dctos_no_le + @sp_mto_prev_volunt   
  
end  
  
----print     'afp6'  
----print     @max_afecto_afp  
  
select @sp_mto_ahorro_volu = 0  
  
if @sp_mto_dcto_cta_ah > 0 AND @sp_unid_cobro_cta is not null   
begin  
----print     'monto descuento'  
----print     @sp_mto_dcto_cta_ah   
----print     @sp_unid_cobro_cta  
   
  select @valor_decimal = 0  
  if @sp_unid_cobro_cta = '$'   
     select @valor_decimal = @sp_mto_dcto_cta_ah  
  else  
     exec  spliq_valores_mon @sp_mes_proceso, @sp_ano_proceso, @sp_empresa, @sp_planta,  
                           @sp_nro_trabajador, @sp_dv_trabajador, @sp_tipo_proceso,  
                           @sp_mto_dcto_cta_ah, @sp_unid_cobro_cta, 523,  
                           @sp_fin_informacio, '', 'N','N', @valor_decimal output  
  
  select @sp_mto_ahorro_volu = round(@valor_decimal, 0)  
  
  if @sp_mto_ahorro_volu = 0  
     INSERT INTO errores_calculo  
         (cod_empresa, cod_planta, nro_trabajador, dv_trabajador,  
          nombre, cod_error_tabla, descripcion_codigo, masivo_informado,  
          descripcion_error, tabla_del_error,cod_tipo_proceso,tipo_error)  
     VALUES (@sp_empresa, @sp_planta, @sp_nro_trabajador, @sp_dv_trabajador,  
          @sp_nombre, 14, 'Revisar montos voluntarios', 'C',  
          'Ahorro voluntario en 0 en Personal', 'Personal',@sp_tipo_proceso,'E')  

  select @sp_tot_dctos_no_le = @sp_tot_dctos_no_le + @sp_mto_ahorro_volu  
  exec  spliq_car_descuen @sp_mes_proceso, @sp_ano_proceso, @sp_empresa,@sp_planta,  
                           @sp_nro_trabajador, @sp_dv_trabajador, @sp_tipo_proceso,  
                           @sp_mto_ahorro_volu,523  
  exec spliq_inserta_des @sp_mes_proceso, @sp_ano_proceso, @sp_empresa, @sp_planta,  
                          @sp_nro_trabajador, @sp_dv_trabajador, @sp_tipo_proceso,523,  
                          @sp_mto_dcto_cta_ah, @sp_unid_cobro_cta,  
                          @sp_mto_ahorro_volu, @sp_cod_centro_cost,@sp_cod_afp,  
                          @sigla_afp_l, @sp_cod_centro_cost, @sp_cod_tipo_trabaj,  
                          @sp_cod_sucursal,0,0, ''  , null
end  
  
--TIPS 26010  
--if @sp_flg_difer_tope = 'S' and @cont = 1 and @sp_nro_dias_enfermo > 0  
--begin  
-- select @max_afecto_afp = @sp_tot_imponible-@sp_afecto_cotizac  
--end  
  
--if @monto_calculo <= 0 and ( @sp_flg_revisa_hist != 'C' and @sp_flg_revisa_hist != 'E' and @sp_flg_revisa_hist != 'P' )   
-- if not (@sp_mto_cotiz_volun > 0 or @sp_mto_dcto_cta_ah > 0 or @sp_mto_cotiz_volu2 > 0)  
-- --return  
  
  
if @sp_nro_dias_asisti + @sp_nro_dias_vacacione = 0 and @sp_flg_difer_tope = 'N'  
  select @max_afecto_afp=0  
  
if @nro_dias_enfermo > 0  
 select @sp_tot_impon_calc=@tot_impon_calc_SIS  
  
  if (@dif_fecha >= 64.999) or (@sp_condic_previsio = 'J' and @monto_aporte_sis = 0)
   begin  
   select @monto_aporte_sis=0  
   select @sp_tot_impon_calc=0  
   end  
   
  
----print     'calc_afp'  
----print     @sp_afecto_cotizac  
   
	   declare @sp_apv_sin_reb numeric(28,10)
	   -- MLB --      
	   select @sp_apv_sin_reb  = isnull(monto_apv_sin_reb,0)
	   from historico_liquidac  
	   where   
	   cod_empresa      = @sp_empresa and  
	   cod_planta       = @sp_planta and  
	   mes_periodo      = @sp_mes_proceso and  
	   ano_periodo      = @sp_ano_proceso and  
	   cod_tipo_proceso = @sp_tipo_proceso and  
	   nro_trabajador   = @sp_nro_trabajador and  
	   dv_trabajador    = @sp_dv_trabajador  
	   
----print     '4) spliq_calc_afp - @sp_apv_sin_reb = ' + convert(varchar(100), @sp_apv_sin_reb)
	   
   
 
----print     '6. spliq_calc_afp - @sp_tot_impon_stg = ' + convert(varchar(100), @sp_tot_impon_stg)
----print     '6. spliq_calc_afp - @sp_afecto_cotizac = ' + convert(varchar(100), @sp_afecto_cotizac)
----print     '6. spliq_calc_afp - @sp_tot_impon_calc = ' + convert(varchar(100), @sp_tot_impon_calc)   
----print     '6. spliq_calc_afp - @monto_aporte_sis = ' + convert(varchar(100), ISNULL(@monto_aporte_sis,0))   
----print     '6. spliq_calc_afp - @sp_afecto_cotizac = ' + convert(varchar(100), ISNULL(@sp_afecto_cotizac,0))   
----print     '6) spliq_calc_afp - @nPorcAplicaSis = ' + convert(varchar(100), @nPorcAplicaSis)
----print     '6) spliq_calc_afp -  @monto_aporte_sis = ' + convert(varchar(100), @monto_aporte_sis)     
----print     '6) spliq_calc_afp -  @@sp_mto_cancela_pre  = ' + convert(varchar(100), @sp_mto_cancela_pre)   
----print     '6) spliq_calc_afp -  @sp_val_leyes_socia  = ' + convert(varchar(100), @sp_val_leyes_socia)   
----print     '6) spliq_calc_afp -  @sp_condic_previsio  = ' + convert(varchar(100), @sp_condic_previsio)   
----print     '6) spliq_calc_afp -  @sp_cod_tipo_jubila  = ' + convert(varchar(100), @sp_cod_tipo_jubila)      
----print     '6) spliq_calc_afp -  @sp_exento_seguro  = ' + convert(varchar(100), @sp_exento_seguro)      
----print     '6) spliq_calc_afp -  @@sp_exento_fondo  = ' + convert(varchar(100), @sp_exento_fondo)       

if (@sp_mto_cancela_pre = 0 and @sp_val_leyes_socia = 0) and (@sp_condic_previsio='J')
	select @sp_afecto_cotizac=0
 
if @sp_tot_impon_calc is null or @sp_tot_impon_calc <0
	select @sp_tot_impon_calc = 0

if @tot_impon_calc_SIS = 0 and @monto_aporte_sis = 0 and @nPorcAplicaSis = 0
	select @tot_impon_calc_SIS = 0
else
	select @tot_impon_calc_SIS = @sp_tot_impon_calc


if @sp_flg_revisa_hist = 'E' or @sp_flg_revisa_hist = 'C' or @sp_flg_revisa_hist = 'P'  
  begin  
    exec spliq_revisa_his @sp_empresa,@sp_planta,@sp_ano_proceso,  
         @sp_mes_proceso,@sp_nro_trabajador,@sp_dv_trabajador, @sp_tipo_proceso,  
         @sp_flg_revisa_hist, @afecto_mutu_otros output  

    if @afecto_mutu_otros > 0  
      begin  
        if @sp_I900 = 1 and @afecto_mutu_otros =0
          select @monto_tope = @sp_monto_afp_I900  
        else  
          select @monto_tope = @sp_tot_imponible  
        if @tot_impon_otros > @monto_tope  
          begin  
            select @afecto_mutual = 0  
          end  
        else  
          begin  
            if ( @tot_impon_otros + @afecto_mutual) > @monto_tope  
              begin  
                select @afecto_mutual = @monto_tope - @tot_impon_otros  
              end  
          end  
      end  
  end  

----print     'CALC_AFP'
----print     @sp_tot_impon_stg
----print     @afecto_mutual
----print     @sp_afecto_cotizac
--SELECT @sp_tot_impon_stg=0

if @mto_pactado_afp > 0
begin
		select @sp_afecto_cotizac = @sp_afecto_cotizac * ((@mto_pactado_afp/100))
end

----print     'Validacion Montos Negativos'
if @sp_tot_impon_stg < 0
	select @sp_tot_impon_stg = 0
if @sp_afecto_cotizac < 0
	select @sp_afecto_cotizac = 0	
if @sp_mto_cancela_pre < 0
	select @sp_mto_cancela_pre = 0	
if @sp_val_leyes_socia < 0
	select @sp_val_leyes_socia = 0	
if @sp_afecto_cotizac < 0
	select @sp_afecto_cotizac = 0	
if @tot_impon_calc_SIS < 0
	select @tot_impon_calc_SIS = 0	
if @afecto_mutual < 0
	select @afecto_mutual = 0	
		

update historico_liquidac set    
total_imponi_ley   = @sp_tot_impon_stg ,  
afecto_cotizacion  = @sp_afecto_cotizac,  
mto_cancela_previs = @sp_mto_cancela_pre,  
val_leyes_sociales = @sp_val_leyes_socia,  
mto_prev_voluntari = @sp_mto_prev_volunt,  
tot_dctos_no_legal = @sp_tot_dctos_no_le,  
mto_ahorro_volunta = @sp_mto_ahorro_volu,  
pje_cotiz_previs   = @nPorcAplica,  
pje_aporte_sis     = @nPorcAplicaSis,  
max_afecto_cotiz   = @max_afecto_afp,  
monto_aporte_sis   = @monto_aporte_sis,  
afecto_mto_sis     = @tot_impon_calc_SIS,  
valor_imponible  = @sp_tot_impon_stg,
afecto_mutual = @afecto_mutual  
where   
cod_empresa      = @sp_empresa        and   
cod_planta       = @sp_planta         and  
mes_periodo      = @sp_mes_proceso    and  
ano_periodo      = @sp_ano_proceso    and  
cod_tipo_proceso = @sp_tipo_proceso   and  
nro_trabajador   = @sp_nro_trabajador and  
dv_trabajador    = @sp_dv_trabajador  
return  





















GO

