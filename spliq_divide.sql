

/****** Object:  StoredProcedure [dbo].[spliq_divide]    Script Date: 07/01/2015 14:17:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spliq_divide]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spliq_divide]
GO



/****** Object:  StoredProcedure [dbo].[spliq_divide]    Script Date: 07/01/2015 14:17:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE  [dbo].[spliq_divide]
@nValor1 numeric(28,10),
@nValor2 numeric(28,10),
@nValor numeric(28,10) output
as

if @nValor1 is null 
 select @nValor1=0

if @nValor2 is null 
 select @nValor2=0

select @nValor1=round(@nValor1,20) * 1.0
select @nValor2=round(@nValor2,20) * 1.0

if @nValor2 > 0
	select  @nValor = round((@nValor1 / @nValor2),20)

return

/****** Object:  StoredProcedure [dbo].[spliq_dividepila]    Script Date: 05/22/2013 11:31:13 ******/
SET ANSI_NULLS OFF

GO

