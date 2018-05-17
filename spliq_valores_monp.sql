/****** Object:  StoredProcedure [dbo].[spliq_valores_monp]    Script Date: 23/03/2018 9:48:22 ******/
DROP PROCEDURE [dbo].[spliq_valores_monp]
GO

/****** Object:  StoredProcedure [dbo].[spliq_valores_monp]    Script Date: 23/03/2018 9:48:22 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO




CREATE PROCEDURE [dbo].[spliq_valores_monp]
    (@sp_mes_proceso int, @sp_ano_proceso int,
     @sp_empresa int, @sp_planta int,
     @sp_nro_trabajador int, @sp_dv_trabajador char(1),
     @sp_tipo_proceso char(4), @cantidad numeric(28,10),
     @moneda char(4), @codigo_hyd int, @fecha_busco datetime,
     @codigo_tabla char(10), @proporciona char(1), @prophab char(1),
     @retorno numeric(28,10) output)

AS
declare
@sp_nombre          char(50),
@sp_descuento       int,
@sp_aporte_especial int,
@sp_tot_impon_stg   numeric(28,10),
@sp_tot_impon_sin_t numeric(28,10),
@sp_nAfecImpo       numeric(28,10),
@sp_vmaximo         numeric(28,10),
@sp_vminimo         numeric(28,10),
@sp_val_leyes_socia int,
@sp_monto_cancel_im int,
@sp_sueldo_ganado_m int,
@sp_gratif int,
@sp_valor_adic_gana int,
@sp_sdo_base_contra int,
@sp_sdos_adic_acumu int,
@sp_asignacion_fami int,
@sp_asig_famil_retr int,
@sp_nro_dias_asisti numeric(28,10),
@sp_nro_dias_enferm numeric(28,10),
@sp_nro_dias_vacaci numeric(28,10),
@sp_valor_especial  numeric(28,10),
@sp_dias_proporcion numeric(28,10),
@sp_dias_prophab numeric(28,10),
@monto_hyd  numeric(28,10),
@valor_tabla numeric(28,10),
@valor_entero int,
@sp_carga_normal int,
@sp_carga_materna int,
@sp_carga_duplo int,
@aplic_liquid char(1),
@valoriza_l char(1),
@tipo_moneda_l char(1),
@proporcion_l Char(1),
@moneda_hyd char(4),
@codigo_busco char(10),
@sp_tot_impto_reliq decimal (13,4),
@sp_nAfecCotizacion numeric(28,10),
@n_Valor_UTM numeric(28,10),
@sp_valor_total_habere int,
@val_alcance_liquido int,
@sp_afecto_sis numeric (13,4),
@ultimo_imponible numeric (13,4),
@ultimo_imponible_tope numeric (13,4),
@sp_afecto_leysanna numeric (13,4),
@valor_decimal numeric (13,4)

declare @val_afecto_mutual numeric(28,10)
----print   'spliq_valores_monp'
----print   @moneda

select @sp_valor_total_habere = 0
select @sp_afecto_leysanna = 0
select @valor_decimal = 0

select @codigo_busco = ''
select @retorno = 0
Select @sp_nombre=nombre, @sp_dias_proporcion=dias_proporcional,
       @sp_nAfecImpo=afecto_imponible, @sp_descuento=descuento,
       @sp_valor_especial=valor_especial,
       @sp_aporte_especial=aporte_especial, @sp_dias_prophab=dias_prop_habil
  From liquidacion
where cod_empresa = @sp_empresa and cod_planta = @sp_planta and
     mes_periodo = @sp_mes_proceso And ano_periodo = @sp_ano_proceso And
     cod_tipo_proceso = @sp_tipo_proceso And
     nro_trabajador =  @sp_nro_trabajador and dv_trabajador = @sp_dv_trabajador

Select @sp_vminimo=val_ingreso_minimo , @sp_vmaximo=val_ingreso_minimo
  From parametro
  Where cod_empresa = @sp_empresa and cod_planta = @sp_planta and
  nro_mes = @sp_mes_proceso and ano = @sp_ano_proceso

Select @sp_sdo_base_contra=sdo_base_contractu, @sp_sdos_adic_acumu=sdos_adic_acumulad,
     @sp_asignacion_fami=asignacion_familia, @sp_asig_famil_retr=asig_famil_retroac,
     @sp_nro_dias_asisti=nro_dias_asistidos, @sp_nro_dias_enferm=nro_dias_enfermo,
     @sp_nro_dias_vacaci=nro_dias_vacacione, @sp_sueldo_ganado_m=sueldo_ganado_mes,
     @sp_valor_adic_gana=valor_adic_ganado, @sp_monto_cancel_im=monto_cancel_impto,
     @sp_val_leyes_socia=val_leyes_sociales, @sp_tot_impon_stg=total_imponi_ley,
     @sp_tot_impon_sin_t=tot_impon_sin_tope, @sp_gratif=haberes_gratificac,
     @sp_carga_normal=nro_cargas_normale, @sp_carga_materna=nro_cargas_materna,
     @sp_carga_duplo=nro_cargas_duplo, @sp_tot_impto_reliq= tot_impto_reliq,
     @sp_nAfecCotizacion=afecto_cotizacion,
     @sp_valor_total_habere=valor_total_habere,
     @val_afecto_mutual=afecto_mutual,
	 @val_alcance_liquido = val_alcance_liquid,
	 @sp_afecto_sis = afecto_mto_sis
From historico_liquidac
where cod_empresa = @sp_empresa and cod_planta = @sp_planta and
     mes_periodo = @sp_mes_proceso And ano_periodo = @sp_ano_proceso And
     cod_tipo_proceso = @sp_tipo_proceso And
     nro_trabajador =  @sp_nro_trabajador and dv_trabajador = @sp_dv_trabajador

SELECT @aplic_liquid=aplic_liquid_sueld, @valoriza_l=valorizado_tabla,
       @tipo_moneda_l=tipo_moneda
     from unidad Where cod_unidad_cobro = @moneda

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
if @ultimo_imponible is null
	select @ultimo_imponible = 0
if @ultimo_imponible_tope is null
	select @ultimo_imponible_tope = 0

select @n_Valor_UTM=val_moneda_unidad from valor_moneda
where cod_unidad_cobro='UTM'
and fec_valor_moneda=@fecha_busco

select @moneda = rtrim(ltrim(@moneda))

     if @tipo_moneda_l = 'P'
      begin
          if @moneda = '%IM'
            begin
             if @sp_aporte_especial = 1
			     begin
					 select @retorno = round(@sp_nAfecCotizacion * (@cantidad / 100.),3)
				 end
			 if @sp_aporte_especial = 5
			     begin
					 select @retorno = round(@val_afecto_mutual * (@cantidad / 100.),3)
				 end
             else
	             begin
		             select @retorno = round(@sp_nAfecImpo  * (@cantidad / 100.),3)
	             end

             if @proporciona = 'S'
             begin
                   select @retorno = @retorno * @sp_dias_proporcion
             end

             if @prophab = 'S'
				begin
					select @retorno = @retorno * @sp_dias_prophab
				end
            end
            
          if @moneda = '%IMS'
            begin
              select @retorno = round(@sp_tot_impon_sin_t * (@cantidad / 100.),3)
              if @proporciona = 'S'  select @retorno = @retorno * @sp_dias_proporcion
              if @proporciona = 'S'  select @retorno = @retorno * @sp_dias_prophab
            end
          if @moneda = '%RET'
            begin
              select @retorno =round( (@sp_tot_impon_sin_t - @sp_val_leyes_socia
                                  - @sp_monto_cancel_im - @sp_tot_impto_reliq ) * (@cantidad / 100.),3)
              if @proporciona = 'S'  select @retorno = @retorno * @sp_dias_proporcion
              if @prophab = 'S'      select @retorno = @retorno * @sp_dias_prophab
            end
          if @moneda = '%SB'
            begin
               if @proporciona = 'S'
                   select @retorno =round( (@sp_sueldo_ganado_m + @sp_valor_adic_gana) *
                                     (@cantidad / 100.),3)
               else
                   select @retorno =round( (@sp_sdo_base_contra + @sp_sdos_adic_acumu) *
                                     (@cantidad / 100.),3)
            end

          if @moneda = '%SBG'
            begin
               if @proporciona = 'S'
                   select @retorno = round((@sp_sueldo_ganado_m + @sp_gratif) *
                                     (@cantidad / 100.),3)
               else
                   select @retorno = round((@sp_sdo_base_contra + @sp_gratif) *
                                     (@cantidad / 100.),3)
            end
          if @moneda = '%SBS'
            begin
               if @proporciona = 'S'
               begin
                   select @retorno = round(@sp_sueldo_ganado_m  * (@cantidad / 100.),3)
               end
               else
               begin

                   select @retorno = round(@sp_sdo_base_contra  * (@cantidad / 100.),3)
               end
            end

          if @moneda = '%ILS'
            begin

			if @sp_nro_dias_enferm > 0 and @sp_nro_dias_asisti = 0
				begin
					if @sp_afecto_sis > 0
						select @sp_afecto_leysanna = @sp_afecto_sis
					else if @sp_afecto_sis = 0 and @ultimo_imponible > 0
						begin
							select @sp_afecto_leysanna = round (@ultimo_imponible / 30,2) * @sp_nro_dias_enferm 
							select @sp_afecto_leysanna = @sp_afecto_leysanna + @sp_nAfecImpo
						--	select @sp_afecto_leysanna = round(@sp_afecto_leysanna * (@cantidad / 100.),3)
						end
					else 
						select @sp_afecto_leysanna = @sp_nAfecImpo
				end
			else if @sp_nro_dias_asisti > 0
				begin
				if @sp_afecto_sis > 0
					select @sp_afecto_leysanna = @sp_afecto_sis
				else if @sp_nAfecImpo > 0
					select @sp_afecto_leysanna = @sp_nAfecImpo
				else
					select @sp_afecto_leysanna = @ultimo_imponible
				end
			else if @sp_nro_dias_asisti = 0
				if @sp_afecto_sis > 0
					select @sp_afecto_leysanna = @sp_afecto_sis
				else if @sp_nAfecImpo > 0
					select @sp_afecto_leysanna = @sp_nAfecImpo



			select @valor_decimal = round(@sp_afecto_leysanna * (@cantidad / 100.),3)	

			--print  'afectos ley sanna'
			--print  @sp_afecto_sis
			--print  @ultimo_imponible
			--print  @sp_nAfecImpo
			--print  @sp_dias_proporcion
			--print  @sp_dias_prophab
			--print  @sp_afecto_leysanna
			--print  @sp_nro_dias_enferm
			--print  @sp_nAfecImpo
			--print @sp_nro_dias_asisti
			--print @sp_afecto_leysanna
			--print  '----'

			 select @retorno = @valor_decimal
			
              if @proporciona = 'S'  
				select @retorno = @retorno * @sp_dias_proporcion
              if @proporciona = 'S'  
				select @retorno = @retorno * @sp_dias_prophab
            
			update historico_liquidac
			set afec_ley_sanna = @sp_afecto_leysanna
			where cod_empresa = @sp_empresa and 
			cod_planta = @sp_planta and
			mes_periodo = @sp_mes_proceso And 
			ano_periodo = @sp_ano_proceso And
			cod_tipo_proceso = @sp_tipo_proceso And
			nro_trabajador =  @sp_nro_trabajador and 
			dv_trabajador = @sp_dv_trabajador
			
			end


  if @moneda = '%BIA'
            begin
			  select @sp_tot_impon_sin_t=@sp_tot_impon_sin_t-(@n_Valor_UTM*10)
              select @retorno = round(@sp_tot_impon_sin_t * (@cantidad / 100.),3)
              if @proporciona = 'S'  select @retorno = @retorno * @sp_dias_proporcion
              if @proporciona = 'S'  select @retorno = @retorno * @sp_dias_prophab
            end



if @moneda = '%SBH'
begin
           select @retorno = round(( @sp_valor_total_habere - @sp_asignacion_fami - @sp_asig_famil_retr - @sp_val_leyes_socia - @sp_monto_cancel_im)  * (@cantidad / 100.),3)
end      

          if @moneda = '%SBC'
            begin
               if @proporciona = 'S'
               begin
                   select @retorno = round((@sp_tot_impon_sin_t - @sp_val_leyes_socia
                                  - @sp_monto_cancel_im )  * (@cantidad / 100.),3)
               end
               else
               begin
                  select @retorno = round((@sp_tot_impon_sin_t - @sp_val_leyes_socia
                                  - @sp_monto_cancel_im )  * (@cantidad / 100.),3)
               end
            end


          if @moneda = '%CFA'
            begin
              select @retorno = (@sp_carga_normal + @sp_carga_materna
              							 + 2 * @sp_carga_duplo)
              exec spliq_valores_monp @sp_mes_proceso, @sp_ano_proceso,
                                 @sp_empresa, @sp_planta, @sp_nro_trabajador,
                                 @sp_dv_trabajador, @sp_tipo_proceso, @retorno,
                                 '%SB', @codigo_hyd, @fecha_busco,
                                 @codigo_tabla, 'N', 'N',  @retorno out
            end
          if @moneda = '%FA'
            begin
               select @retorno =round( (@sp_asignacion_fami + @sp_asig_famil_retr) *
                                 (@cantidad / 100),3)
               if @proporciona = 'S'  select @retorno = @retorno * @sp_dias_proporcion
               if @prophab = 'S'      select @retorno = @retorno * @sp_dias_prophab
            end
          if @moneda = '%LI'
            begin
               select @retorno = round((@sp_tot_impon_sin_t - @sp_val_leyes_socia
                                  - @sp_monto_cancel_im) * (@cantidad / 100.),3)
               if @proporciona = 'S'  select @retorno = @retorno * @sp_dias_proporcion
               if @prophab = 'S'      select @retorno = @retorno * @sp_dias_prophab
            end
          if @moneda = '%IMA'
            begin
              if @sp_nAfecImpo < @sp_vminimo
  begin
   select @retorno = round(@sp_vminimo * (@cantidad / 100.),3)
                   select @sp_valor_especial = @sp_vminimo
                end
              else
                begin
                  if @sp_nAfecImpo > @sp_vmaximo
                     begin
                        select @retorno = round(@sp_vmaximo * (@cantidad / 100.),3)
                        select @sp_valor_especial = @sp_vmaximo
                     end
                  else
                    begin
                      select @retorno = round(@sp_nAfecImpo * (@cantidad / 100.),3)
                      select @sp_valor_especial = @sp_nAfecImpo
                    end
                end

             if @proporciona = 'S'
                select @retorno = @retorno * @sp_dias_proporcion

             if @prophab = 'S'
                 select @retorno = @retorno * @sp_dias_prophab

            end
 
           if @moneda = '%AL'
            begin
			--------print   'aqui'
		--	------print   @val_alcance_liquido
              select @val_alcance_liquido =(@sp_valor_total_habere - (@sp_val_leyes_socia + @sp_monto_cancel_im ))
              select @retorno = round(@val_alcance_liquido * (@cantidad / 100.),3)
              if @proporciona = 'S'  select @retorno = @retorno * @sp_dias_proporcion
              if @proporciona = 'S'  select @retorno = @retorno * @sp_dias_prophab
            end
         end

if @retorno is null
begin
 select @retorno = 0
end
return



















GO

