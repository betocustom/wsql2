/****** Object:  StoredProcedure [dbo].[spliq_comp_llss_reliq]    Script Date: 04/26/2018 01:19:02 ******/
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[spliq_comp_llss_reliq]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[spliq_comp_llss_reliq]
GO

/****** Object:  StoredProcedure [dbo].[spliq_comp_llss_reliq]    Script Date: 04/26/2018 01:19:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


 


CREATE PROCEDURE [dbo].[spliq_comp_llss_reliq]
(@sp_mes_proceso int,@sp_ano_proceso int,@sp_empresa int,@sp_planta int,
@sp_nro_trabajador int,@sp_dv_trabajador char(1),@base_cada_mes char(1),
@sp_consolida_empresa char(1),@valor_afecto_cotiza numeric(28,10),
@valor_afecto_cotiza_ley numeric(28,10),@val_afecto_cotiza_seg numeric(28,10),@valor_afecto_sis numeric(28,10),
@mto_desahucio numeric(28,10) output,@mto_prevision numeric(28,10) output,
@mto_salud_legal numeric(28,10) output,@mto_pagado_ccaf numeric(28,10) output,@salud_voluntaria numeric(28,10) output,
@salud_adicional numeric(28,10) output,@valor_seguro_des numeric(28,10) output, @monto_aporte_sis numeric(28,10) output, @dias_licencia int)
as
declare @pje_salud_legal decimal(5,2),@mto_tope_prev_peso numeric(28,10),
        @tope_salud_pesos numeric(28,10),@pje_fonasa decimal(5,2),@pje_cotiz_salud decimal(5,2),
@pje_ccaf decimal(5,2),@pje_cotzado_caja decimal(5,2),@pje_cotzado_caja_his decimal(5,2),@pje_cotiz_salud_his decimal(5,2)
declare @pje_aporte_trab_a decimal(5,2), @pje_aporte_trab_j decimal(5,2)
declare @cod_afp int,@cod_isapre int,@cod_caja_prevision int,@cod_instit_previsi int,@cod_instit_salud int,
@caja_comp_antigua int,@aplica_seguro_his char(1),@cod_tipo_cont_his char(1) 
declare @pje_cotiz_previsio decimal(5,2),@pje_cotiz_prev_his decimal(5,2),@pje_aporte_sis_his decimal(5,2),@pje_salud decimal(5,2),@pje_pension_seguro decimal(5,2),
@pje_desahucio decimal(5,2),@pje_desahucio_his decimal(5,2)
declare @mto_pactado_isapre numeric(28,10), @valor_pactado_isapre numeric(28,10)
declare @adicional_isapre numeric(28,10), @val_volunt_isapre numeric(28,10)
declare @unid_cob_mto_pacta char(4), @mone_val_adic_salu char(4)
declare @sfecha_moneda char(10),@aplica_seguro_des char(1),@cod_tipo_contra char(1)
declare @fecha_moneda datetime, @sp_flg_aporte_sis char(1)
declare @condic_previsional char(1), @exento_seguro  char(1),
        @exento_fondo char(1), @cod_cancela_isapre char(1),
        @sp_nro_dias_asisti int,@sp_nro_dias_vacacio int, @sp_nro_dias_enfermo int ,@sp_nro_dias_ausente_i int,@sp_nro_dias_ausente_f int,
        @sp_flg_ause_i char(1), @sp_flg_ause_f char(1), @dias_prop_isapre int, @dias_prop_isap_ause int
declare @pje_aporte_emp_j decimal(5,2), @pje_aporte_emp_a  decimal(5,2)
declare @fecha_nacimiento datetime, @dif_fecha int, @cod_sexo char(1)
declare @val_afecto_cotiza_seg2 numeric(28,10)
declare @cod_tipo_invalidez int
declare @flg_no_reb_jub char(1), @sp_fec_mod_tip_con datetime, @sp_fec_mod_tip_his datetime, @PeriodoF int, @PeriodoP int
    
select @dif_fecha             = 0
select @monto_aporte_sis      = 0
select @dias_prop_isap_ause   = 0
select @dias_prop_isapre      = 0
select @sp_nro_dias_ausente_i = 0
select @sp_nro_dias_ausente_f = 0
select @salud_adicional       = 0
select @salud_voluntaria      = 0
select @val_volunt_isapre     = 0
select @pje_salud_legal       = 0
select @mto_tope_prev_peso    = 0
select @tope_salud_pesos      = 0
select @pje_fonasa            = 0
select @pje_ccaf              = 0
select @mto_prevision         = 0
select @mto_desahucio         = 0
select @mto_salud_legal       = 0
select @sp_flg_ause_i         = ''
select @sp_flg_ause_f         = ''
select @sp_fec_mod_tip_con   = null
select @sp_fec_mod_tip_his   = null

select @fecha_moneda=fec_fin_info_perio
from control_procesos
where
cod_empresa        = @sp_empresa     and
cod_planta         = @sp_planta      and
ano_proc_cont_proc = @sp_ano_proceso and
cod_mes_proceso    = @sp_mes_proceso

select @sfecha_moneda= ltrim(rtrim(convert(char(10),@fecha_moneda,103)))

select @pje_salud_legal    = pje_salud_legal,
       @mto_tope_prev_peso = mto_tope_prev_peso,
       @tope_salud_pesos   = tope_salud_pesos,
       @pje_fonasa         = pje_fonasa,
       @pje_ccaf           = isnull(pje_ccaf,0)
from parametro
where
cod_empresa = @sp_empresa     and
cod_planta  = @sp_planta      and
ano         = @sp_ano_proceso and
nro_mes     = @sp_mes_proceso

select @sp_flg_ause_i     = prop_isap_ingreso,
       @sp_flg_ause_f     = prop_isap_egreso,
       @sp_flg_aporte_sis = flg_aporte_sis
from control_parametros
where
cod_empresa        = @sp_empresa and
cod_planta         = @sp_planta and
ano_control_proces = @sp_ano_proceso and
mes_control_proces = @sp_mes_proceso

if @sp_flg_ause_i     is null select @sp_flg_ause_i     = 'S'
if @sp_flg_ause_f     is null select @sp_flg_ause_f     = 'S'
if @sp_flg_aporte_sis is null select @sp_flg_aporte_sis = 'N'



if @sp_consolida_empresa = 'N'
  begin
    select   @sp_nro_dias_ausente_i = ausente_contrato_i,
             @sp_nro_dias_ausente_f = ausente_contrato_f
    from liquidacion
    where 
    cod_empresa      = @sp_empresa        and
    cod_planta       = @sp_planta         and
    cod_tipo_proceso = 'LQ'               and
    ano_periodo      = @sp_ano_proceso    and
    mes_periodo      = @sp_mes_proceso    and
    nro_trabajador   = @sp_nro_trabajador and
    dv_trabajador    = @sp_dv_trabajador
    select @sp_nro_dias_asisti   = nro_dias_asistidos,
           @sp_nro_dias_vacacio  = nro_dias_vacacione,
           @sp_nro_dias_enfermo  = nro_dias_enfermo,
           @aplica_seguro_his    = aplica_seguro_des,
           @cod_tipo_cont_his    = codigo_tipo_contra,
           @pje_cotiz_prev_his   = pje_cotiz_previs,
           @pje_aporte_sis_his   = pje_aporte_sis,
           @pje_cotiz_salud_his  = pje_cotiz_salud,
           @pje_cotzado_caja_his = pje_cotzado_caja,
           @pje_desahucio_his    = pje_desahucio ,
           @sp_fec_mod_tip_his	=  fec_mod_tipo_contr 
    from historico_liquidac
    where
    cod_empresa      = @sp_empresa        and
    cod_planta       = @sp_planta         and
    cod_tipo_proceso = 'LQ'               and
    ano_periodo      = @sp_ano_proceso    and
    mes_periodo      = @sp_mes_proceso    and
    nro_trabajador   = @sp_nro_trabajador and
    dv_trabajador    = @sp_dv_trabajador
  end
else
  begin
    select   @sp_nro_dias_ausente_i = ausente_contrato_i,
             @sp_nro_dias_ausente_f = ausente_contrato_f
    from liquidacion
    where 
    cod_empresa      = @sp_empresa        and
    cod_tipo_proceso = 'LQ'               and
    ano_periodo      = @sp_ano_proceso    and
    mes_periodo      = @sp_mes_proceso    and
    nro_trabajador   = @sp_nro_trabajador and
    dv_trabajador    = @sp_dv_trabajador
    select @sp_nro_dias_asisti   = nro_dias_asistidos,
           @sp_nro_dias_vacacio  = nro_dias_vacacione,
           @sp_nro_dias_enfermo  = nro_dias_enfermo,
           @aplica_seguro_his    = aplica_seguro_des,
           @cod_tipo_cont_his    = codigo_tipo_contra,
           @pje_cotiz_prev_his   = pje_cotiz_previs,
           @pje_aporte_sis_his   = pje_aporte_sis,
           @pje_cotiz_salud_his  = pje_cotiz_salud,
           @pje_cotzado_caja_his = pje_cotzado_caja,
           @pje_desahucio_his    = pje_desahucio ,
           @sp_fec_mod_tip_his	=  fec_mod_tipo_contr 
    from historico_liquidac
    where
    cod_empresa      = @sp_empresa        and
    cod_tipo_proceso = 'LQ'               and
    ano_periodo      = @sp_ano_proceso    and
    mes_periodo      = @sp_mes_proceso    and
    nro_trabajador   = @sp_nro_trabajador and
    dv_trabajador    = @sp_dv_trabajador
  end


select @cod_afp            = isnull(cod_afp,0),
       @cod_isapre         = isnull(cod_isapre,0),
       @cod_caja_prevision = isnull(cod_caja_prevision,0),
       @mto_pactado_isapre = isnull(mto_pactado_isapre,0),
       @unid_cob_mto_pacta = unid_cob_mto_pacta,
       @adicional_isapre   = adicional_isapre,
       @mone_val_adic_salu = mone_val_adic_salu,
       @aplica_seguro_des  = aplica_seguro_des,
       @cod_tipo_contra    = codigo_tipo_contra, 
       @cod_cancela_isapre = cod_cancela_isapre,
       @fecha_nacimiento   = fec_nacimiento,
       @cod_sexo           = cod_sexo,
       @condic_previsional = condic_previsional,
       @exento_seguro      = exento_seguro,
       @exento_fondo       = exento_fondo,
       @cod_tipo_invalidez	= cod_tipo_invalidez, 
	   @flg_no_reb_jub      =  flg_no_reb_jub,
       @sp_fec_mod_tip_con	=  fec_mod_tipo_contr
from personal
where
cod_empresa    = @sp_empresa and
cod_planta     = @sp_planta and
nro_trabajador = @sp_nro_trabajador and
dv_trabajador  = @sp_dv_trabajador

   
if @flg_no_reb_jub is null or @flg_no_reb_jub = '' or @flg_no_reb_jub = ' '
		select @flg_no_reb_jub = 'N'




if @base_cada_mes = 'N'
  begin
    if @cod_afp > 0
      begin
        if @condic_previsional='J'
          begin
            if @exento_seguro='S'
              begin
                select @pje_cotiz_previsio = pje_ex_seg_invalid,
                       @pje_aporte_trab_j  = pje_aporte_trab_j,
                       @pje_aporte_emp_j   = pje_aporte_emp_j 
                from afp 
                where cod_afp = @cod_afp
                
                if @sp_flg_aporte_sis = 'S'
                  begin
                    select @mto_prevision  = round((@valor_afecto_cotiza * @pje_aporte_trab_j) / 100,4)
                    select @monto_aporte_sis = round((@valor_afecto_sis * @pje_aporte_emp_j) / 100,4)                
                  end
                else  
                  select @mto_prevision  = round((@valor_afecto_cotiza * @pje_cotiz_previsio) / 100,4)                
                
              end
            if @exento_fondo = 'S'
              begin
                select @pje_cotiz_previsio = 0
                select @mto_prevision      = 0
                select @monto_aporte_sis   = 0
              end
          end
        else
          begin

            select @dif_fecha = convert(int,datediff(dd,@fecha_nacimiento,@fecha_moneda) / 365.25)

            if ( ( @dif_fecha >= 60 and @cod_sexo = 'F' ) OR ( @dif_fecha >= 65 and @cod_sexo = 'M' ) ) and @flg_no_reb_jub = 'N'
              begin
              
                select @pje_cotiz_previsio =pje_ex_seg_invalid,
                @pje_aporte_trab_j  = pje_aporte_trab_j ,
                @pje_aporte_emp_j = pje_aporte_emp_j
                from afp where cod_afp=@cod_afp
                
                if @dif_fecha >= 65
                begin
					select @monto_aporte_sis = 0
					select @mto_prevision  = 0
                end
                else    
                begin            
					if @sp_flg_aporte_sis = 'S'
					  begin                  
						select @monto_aporte_sis = round((@valor_afecto_sis * @pje_aporte_emp_j) / 100,4)   
						select @mto_prevision  = 0
					  end
					else
					  select @mto_prevision  = 0
                end
              end              
            else
              begin
               
                select @pje_cotiz_previsio = pje_cotiz_previsio,
                @pje_aporte_trab_a  = pje_aporte_trab_a,
                @pje_aporte_emp_a   = pje_aporte_emp_a from afp where cod_afp = @cod_afp
                if @sp_flg_aporte_sis = 'S'
                  begin
                  
                   if @dif_fecha >= 65
					begin
						select @monto_aporte_sis = 0
					end
					else
					begin
						select @monto_aporte_sis = round((@valor_afecto_sis * @pje_aporte_emp_a) / 100,4)     
					end
                    select @mto_prevision  = round((@valor_afecto_cotiza * @pje_aporte_trab_a) / 100,4)
                    
                  end
                else
                  select @mto_prevision  = round((@valor_afecto_cotiza * @pje_cotiz_previsio) / 100,4)                  
              end
            
          end
      end
      
             
    if @cod_caja_prevision > 0 and @cod_isapre <= 1
      begin
        select @pje_ccaf           = isnull(pje_ccaf,0),
               @pje_salud          = isnull(pje_salud,0),
               @pje_pension_seguro = isnull(pje_pension_seguro,0),
               @pje_desahucio      = isnull(pje_desahucio,0)
        from caja_prevision where cod_caja_prevision = @cod_caja_prevision
        select @mto_desahucio   = round((@valor_afecto_cotiza_ley * @pje_desahucio ) / 100,4)
        select @mto_prevision   = round((@valor_afecto_cotiza_ley * @pje_pension_seguro) / 100,4)
      end
    else if @cod_caja_prevision > 0 and @cod_isapre > 1
      begin
        select @pje_ccaf           = isnull(pje_ccaf,0),
               @pje_salud          = isnull(pje_salud,0),
               @pje_pension_seguro = isnull(pje_pension_seguro,0),
               @pje_desahucio      = isnull(pje_desahucio,0)
        from caja_prevision where cod_caja_prevision = @cod_caja_prevision
        select @mto_desahucio   = round((@valor_afecto_cotiza_ley * @pje_desahucio ) / 100,4)
        select @mto_prevision   = round((@valor_afecto_cotiza_ley * @pje_pension_seguro) / 100 ,4)
      end
      
      
    
    if @cod_isapre > 1
      begin
		 if @cod_afp > 0 and @valor_afecto_cotiza != 0 and @condic_previsional != 'J'
			 select @mto_salud_legal = round((@valor_afecto_cotiza * @pje_salud_legal) / 100,4)
		else		
			 select @mto_salud_legal = round((@valor_afecto_cotiza_ley * @pje_salud_legal) / 100,4)
		
        select @mto_pagado_ccaf = 0
      end
    else
      begin
        select @mto_salud_legal = round((@valor_afecto_cotiza_ley * @pje_fonasa) / 100,4)
        select @mto_pagado_ccaf = round((@valor_afecto_cotiza_ley * @pje_ccaf) / 100,4)
      end
  end
else
  begin
    if @cod_afp > 0
	  
	  select @pje_aporte_emp_j   = pje_aporte_emp_j 
      from	afp 
      where cod_afp = @cod_afp
                
      begin
        if @condic_previsional='J'
          begin
            if @exento_seguro='S' 
              begin
                select @mto_prevision    = round((@valor_afecto_cotiza * @pje_cotiz_prev_his) / 100,4)
                
                select @dif_fecha=convert(int,datediff(dd,@fecha_nacimiento,@fecha_moneda) / 365.25)
				if ( @dif_fecha >= 65 and @cod_sexo = 'F' ) OR ( @dif_fecha >= 65 and @cod_sexo = 'M' )
				  begin
               		select @monto_aporte_sis = round((@valor_afecto_sis * @pje_aporte_emp_j) / 100,4)
				  end
				else
				begin
					select @monto_aporte_sis = round((@valor_afecto_sis * @pje_aporte_sis_his) / 100,4)
				end
			
              end           
            if @exento_fondo='S'
              begin
                select @pje_cotiz_previsio = 0
                select @mto_prevision      = 0
                select @monto_aporte_sis   = 0
              end
          end
        else
          begin 
            select @mto_prevision    = round((@valor_afecto_cotiza * @pje_cotiz_prev_his) / 100,4)
            
            select @dif_fecha=convert(int,datediff(dd,@fecha_nacimiento,@fecha_moneda) / 365.25)
            if ( @dif_fecha >= 65 and @cod_sexo = 'F' ) OR ( @dif_fecha >= 65 and @cod_sexo = 'M' )
              begin
               	select @monto_aporte_sis = round((@valor_afecto_sis * @pje_aporte_emp_j) / 100,4)
			  end
			else
			begin
				select @monto_aporte_sis = round((@valor_afecto_sis * @pje_aporte_sis_his) / 100,4)
			end
          end
      end
      
    if @cod_caja_prevision > 0 and @cod_isapre <= 1
      begin
        select @pje_ccaf           = isnull(pje_ccaf,0),
               @pje_salud          = isnull(pje_salud,0),
               @pje_pension_seguro = isnull(pje_pension_seguro,0),
               @pje_desahucio      = isnull(pje_desahucio,0)
        from caja_prevision where cod_caja_prevision = @cod_caja_prevision
        select @mto_desahucio   = round((@valor_afecto_cotiza_ley * @pje_desahucio_his ) / 100,4)
        select @mto_prevision   = round((@valor_afecto_cotiza_ley * @pje_cotiz_prev_his) / 100,4)
      end
    else if @cod_caja_prevision > 0 and @cod_isapre > 1
      begin
        select @pje_ccaf           = isnull(pje_ccaf,0),
               @pje_salud          = isnull(pje_salud,0),
               @pje_pension_seguro = isnull(pje_pension_seguro,0),
               @pje_desahucio      = isnull(pje_desahucio,0)
        from caja_prevision where cod_caja_prevision = @cod_caja_prevision
        select @mto_desahucio   = round((@valor_afecto_cotiza_ley * @pje_desahucio_his) / 100,4)
        select @mto_prevision   = round((@valor_afecto_cotiza_ley * @pje_cotiz_prev_his) / 100 ,4)
      end
    if @cod_isapre > 1
      begin
		if @cod_afp > 0 and @valor_afecto_cotiza != 0 and @condic_previsional != 'J'
			 select @mto_salud_legal = round((@valor_afecto_cotiza * @pje_salud_legal) / 100,4)
		else
			 select @mto_salud_legal = round((@valor_afecto_cotiza_ley * @pje_salud_legal) / 100,4)	
		
        select @mto_pagado_ccaf = 0
      end
    else if @cod_isapre = 1
      begin
        select @mto_salud_legal = round((@valor_afecto_cotiza_ley * @pje_fonasa) / 100,4)
        select @mto_pagado_ccaf = round((@valor_afecto_cotiza_ley * @pje_ccaf) / 100,4)
      end
    else
      begin
        select @mto_salud_legal = 0
        select @mto_pagado_ccaf = 0
      end
      
  end
--verif si tiene que cotizar por el pactado o s¢lo 7%
select @mto_pactado_isapre = 0
select @adicional_isapre = 0

if @mto_pactado_isapre > 0 and not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
  begin
    exec spliq_valores_mon_reliq @sp_mes_proceso, @sp_ano_proceso, @sp_empresa, @sp_planta,
         @sp_nro_trabajador, @sp_dv_trabajador, 'LQ', @mto_pactado_isapre,
         @unid_cob_mto_pacta,506,@sfecha_moneda,'','N','N',@valor_pactado_isapre output
    select @valor_pactado_isapre = round(@valor_pactado_isapre,0)
  end
if @valor_pactado_isapre is null select @valor_pactado_isapre = 0

if @adicional_isapre > 0 and @adicional_isapre < 100
  begin
    exec spliq_valores_mon_reliq @sp_mes_proceso, @sp_ano_proceso, @sp_empresa, @sp_planta,
         @sp_nro_trabajador, @sp_dv_trabajador, 'LQ', @adicional_isapre,'UF',506,
         @sfecha_moneda,'','N','N',@val_volunt_isapre output
    select @val_volunt_isapre = round(@val_volunt_isapre,0)
    if @val_volunt_isapre is null select @val_volunt_isapre = 0
  end

if @adicional_isapre > 0 and @adicional_isapre >= 100
  select @val_volunt_isapre = @adicional_isapre 
if @valor_pactado_isapre = 0
  select @valor_pactado_isapre = @mto_salud_legal 
if (@valor_pactado_isapre + @val_volunt_isapre) <= @mto_salud_legal
  select @valor_pactado_isapre = @mto_salud_legal - @val_volunt_isapre

select @valor_pactado_isapre = @valor_pactado_isapre + @val_volunt_isapre

if @sp_flg_ause_i = 'S'
  select @dias_prop_isapre = @sp_nro_dias_ausente_i
if @sp_flg_ause_f = 'S'
  select @dias_prop_isapre = @dias_prop_isapre + @sp_nro_dias_ausente_f

if @sp_consolida_empresa = 'N'
  select @dias_prop_isap_ause = sum(cantidad) 
  from movimiento_ausenci a,ausencia b
  where
  a.cod_empresa       = @sp_empresa and
  a.cod_planta        = @sp_planta and
  a.cod_empresa       = b.cod_empresa and
  a.cod_planta        = b.cod_planta and
  a.cod_ausencia      = b.cod_ausencia and
  a.nro_trabajador    = @sp_nro_trabajador and
  a.dv_trabajador     = @sp_dv_trabajador and
  b.prop_pactado_isap = 'S'
else
  select @dias_prop_isap_ause = sum(cantidad) 
  from movimiento_ausenci a,ausencia b
  where
  a.cod_empresa       = @sp_empresa and
  a.cod_empresa       = b.cod_empresa and
  a.cod_planta        = b.cod_planta and
  a.cod_ausencia      = b.cod_ausencia and
  a.nro_trabajador    = @sp_nro_trabajador and
  a.dv_trabajador     = @sp_dv_trabajador and
  b.prop_pactado_isap = 'S'

if @dias_prop_isap_ause is null select @dias_prop_isap_ause = 0
select @dias_prop_isapre = @dias_prop_isapre + @dias_prop_isap_ause

if @dias_licencia > 0
  begin
    if @condic_previsional='J'
      begin
        if @cod_cancela_isapre='N'
          begin
            select @mto_salud_legal = 0
            select @salud_adicional = 0
          end
        else if @cod_cancela_isapre='M'
          begin
            select @mto_salud_legal = @valor_pactado_isapre
            select @salud_adicional = 0
          end
        else
          begin
            if @mto_pactado_isapre > 0 and @valor_pactado_isapre > @tope_salud_pesos and
               not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
              begin
                select @valor_pactado_isapre = round((@valor_pactado_isapre / 30 *( 30 - @dias_prop_isapre ))  + round((@val_volunt_isapre/30)*( 30 - @dias_prop_isapre ),0),0)
                select @salud_adicional = @valor_pactado_isapre - ( @tope_salud_pesos) / 30 *(30 - @sp_nro_dias_enfermo)
                select @mto_salud_legal = round(@tope_salud_pesos / 30 *(30 - @sp_nro_dias_enfermo),0)
              end
            else
              if @mto_pactado_isapre > 0 and  @valor_pactado_isapre <= @tope_salud_pesos and
                 @valor_pactado_isapre < (round(@valor_afecto_cotiza * @pje_salud_legal/100,0)) and
                 not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
                begin
                  select @salud_adicional = 0
                  select @mto_salud_legal = round(@valor_afecto_cotiza * @pje_salud_legal/100,0)
                end
              else
                if @mto_pactado_isapre > 0 and  @valor_pactado_isapre <= @tope_salud_pesos and
                   @valor_pactado_isapre > (round(@valor_afecto_cotiza*@pje_salud_legal/100,0)) and 
                   not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
                  begin
                    select @salud_adicional = 0
                    select @mto_salud_legal = round(@valor_pactado_isapre / 30 *( 30 - @dias_prop_isapre ),0)
                  end
          end
      end
    else
      begin
        if @mto_pactado_isapre > 0 and @valor_pactado_isapre > @tope_salud_pesos and
           not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
          begin
            select @valor_pactado_isapre = round((@valor_pactado_isapre / 30 * ( 30 - @dias_prop_isapre ))  + (@val_volunt_isapre / 30 *( 30 - @dias_prop_isapre )),0)
            select @salud_adicional = @valor_pactado_isapre - ( @tope_salud_pesos) / 30 *((@sp_nro_dias_asisti+@sp_nro_dias_vacacio))
            select @mto_salud_legal = round(@tope_salud_pesos / 30 *(30-@sp_nro_dias_enfermo),0)
          end
        else
          if @mto_pactado_isapre > 0 and  @valor_pactado_isapre <= @tope_salud_pesos and
             (@valor_pactado_isapre/30*(30-@dias_licencia)) < (round(@valor_afecto_cotiza*@pje_salud_legal/100,0)) and
             not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
            begin
              select @salud_adicional = 0
              select @mto_salud_legal = round(@valor_afecto_cotiza*@pje_salud_legal/100,0)
            end
          else
            if @mto_pactado_isapre > 0 and  @valor_pactado_isapre <= @tope_salud_pesos and
               @valor_pactado_isapre > (round(@valor_afecto_cotiza*@pje_salud_legal/100,0)) and
               not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
              begin
                select @salud_adicional = 0
                select @mto_salud_legal = @valor_pactado_isapre / 30 *( 30 - @dias_prop_isapre )
              end
            else
              if @valor_pactado_isapre <= @tope_salud_pesos and
                 @valor_pactado_isapre  > (round(@valor_afecto_cotiza*@pje_salud_legal/100,0)) and
                 not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
                begin
                  select @salud_adicional = 0
                  select @mto_salud_legal = @valor_pactado_isapre
                end
      end
  end
else
  begin
    if @condic_previsional='J'
      begin
        if @cod_cancela_isapre='N'
          begin
            select @mto_salud_legal = 0
            select @salud_adicional = 0
          end
        else if @cod_cancela_isapre='M'
          begin
            select @mto_salud_legal = @valor_pactado_isapre
            select @salud_adicional = 0
          end
        else
          begin
            if @mto_pactado_isapre > 0 and @valor_pactado_isapre > @tope_salud_pesos and
               not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
              begin
                select @salud_adicional = @valor_pactado_isapre - @tope_salud_pesos
                select @mto_salud_legal = @tope_salud_pesos 
              end
            else
              if @mto_pactado_isapre > 0 and  @valor_pactado_isapre <= @tope_salud_pesos and
                 @valor_pactado_isapre  < (round(@valor_afecto_cotiza*@pje_salud_legal/100,0)) and
                 not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
                begin
                  select @salud_adicional = 0
                  select @mto_salud_legal = round(@valor_afecto_cotiza*@pje_salud_legal/100,0)
                end
              else
                if @mto_pactado_isapre > 0 and  @valor_pactado_isapre <= @tope_salud_pesos and
                   @valor_pactado_isapre > (round(@valor_afecto_cotiza*@pje_salud_legal/100,0)) and
                   not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
                  begin
                    select @salud_adicional = 0
                    select @mto_salud_legal = @valor_pactado_isapre
                  end
                else
                  if @valor_pactado_isapre <= @tope_salud_pesos and
                     @valor_pactado_isapre  > (round(@valor_afecto_cotiza*@pje_salud_legal/100,0)) and
                     not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
                    begin
                      select @salud_adicional = 0
                      select @mto_salud_legal = @valor_pactado_isapre
                    end
          end
      end
    else
      begin
        if @valor_pactado_isapre <= @tope_salud_pesos and
           not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
          begin
            select @salud_adicional = 0
            select @mto_salud_legal = @valor_pactado_isapre 
          end
        else
          if @mto_pactado_isapre > 0 and @valor_pactado_isapre > @tope_salud_pesos and
             not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
            begin
              select @salud_adicional = @valor_pactado_isapre - @tope_salud_pesos
              select @mto_salud_legal = @tope_salud_pesos 
            end
          else
            if @valor_pactado_isapre > @tope_salud_pesos and
              not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
              begin
                select @salud_adicional = @valor_pactado_isapre - @tope_salud_pesos
                select @mto_salud_legal = @tope_salud_pesos 
              end
            else
              if @mto_pactado_isapre > 0 and  @valor_pactado_isapre <= @tope_salud_pesos and
                 @valor_pactado_isapre  < (round(@valor_afecto_cotiza*@pje_salud_legal/100,0)) and
                 not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
                begin
                  select @salud_adicional = 0
                  select @mto_salud_legal = round(@valor_afecto_cotiza*@pje_salud_legal/100,0)
                end
              else
                if @mto_pactado_isapre > 0 and  @valor_pactado_isapre <= @tope_salud_pesos and
                   @valor_pactado_isapre  < (round(@valor_afecto_cotiza*@pje_salud_legal/100,0)) and
                   not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
                  begin
                    select @salud_adicional = 0
                    select @mto_salud_legal = @valor_pactado_isapre
                  end
                else
                  if @valor_pactado_isapre <= @tope_salud_pesos and
                     @valor_pactado_isapre  > (round(@valor_afecto_cotiza*@pje_salud_legal/100,0)) and
                     not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
                    begin
                      select @salud_adicional = 0
                      select @mto_salud_legal = @valor_pactado_isapre
                    end
                  else
                    if @mto_pactado_isapre > 0 and  @valor_pactado_isapre <= @tope_salud_pesos and
                       @valor_pactado_isapre > (round(@valor_afecto_cotiza*@pje_salud_legal/100,0)) and
                       not ( @mto_pactado_isapre = @pje_salud_legal and rtrim(ltrim(@unid_cob_mto_pacta)) = '%IM' )
                      begin
                        select @salud_adicional = 0
                        select @mto_salud_legal = @valor_pactado_isapre
                      end
      end
  end

if @base_cada_mes = 'N' or @base_cada_mes is null
  if @aplica_seguro_des = 'S' and @cod_tipo_contra ='P'
    select @valor_seguro_des = round((@val_afecto_cotiza_seg * 6) /1000 , 4)
  else
    select @valor_seguro_des = 0
else
  set @sp_fec_mod_tip_con = @sp_fec_mod_tip_his
  if @aplica_seguro_his = 'S' and @cod_tipo_cont_his ='P'
    select @valor_seguro_des = round((@val_afecto_cotiza_seg * 6) /1000 , 4)
  else
    select @valor_seguro_des = 0


if ( @sp_fec_mod_tip_con is not null )
   begin
		set @PeriodoF = YEAR(@sp_fec_mod_tip_con)*100+MONTH(@sp_fec_mod_tip_con)
		set @PeriodoP = @sp_ano_proceso*100+@sp_mes_proceso	
		if ( @PeriodoP < @PeriodoF )
			select @valor_seguro_des = 0
	end
		 
		

if @condic_previsional='J'
	select @monto_aporte_sis = 0
    
if ( @cod_tipo_invalidez = 2 or @cod_tipo_invalidez is null )
begin
	if @condic_previsional='J'
	  select @valor_seguro_des= 0
end

return







GO

