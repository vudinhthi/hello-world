USE [ColorMix]
GO
/****** Object:  StoredProcedure [dbo].[sp_checkOverWeight]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[sp_checkOverWeight]
@TrackType varchar(10)='', 
@Barcode varchar(100)='', 
@ScaleWeight numeric(6,1)=0
as



--Trộn (COMPOUND)
IF @TrackType='MIX'
BEGIN 
		
		Declare @DefaultWeight numeric(6,1)
		Declare @CurrentWeight numeric(6,1)
		declare @OverWeightId varchar(50)
		--Declare @IncreaseWeight numeric(6,1)

		set @OverWeightId=isnull(( select top 1 OverWeightId from SSBC_OverWeight where ProForBacode=@Barcode order by  seq desc),'')

		set @CurrentWeight=(select sum(ScaleWeight) from SSBC_Mix_Trackings where ProForBacode=@Barcode  and isnull(OverWeightId,'')=@OverWeightId )
		set @DefaultWeight=(select TotalQty from SSBC_MixVouchers where VoucherId=SUBSTRING(@Barcode,4,LEN(@Barcode)-6))

		set @DefaultWeight=@DefaultWeight+(@DefaultWeight*0.1) --giới hạn 10%

		--set @IncreaseWeight=@DefaultWeight*0.1

		
		if(@CurrentWeight+@ScaleWeight)>@DefaultWeight
		begin
			select N'OverWeight' as Msg
			return
		end
	
		select N'No Over' as Msg

END



GO
/****** Object:  StoredProcedure [dbo].[sp_createCrushRaw]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Name :       sp_createCrushRaw
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Insert a new Crushraw>
-- =============================================
CREATE PROCEDURE [dbo].[sp_createCrushRaw] 
	-- Add the parameters for the stored procedure here
	@shiftID		nvarchar(50)='',
	@operatorCode	nvarchar(100)='',
	@productCode	nvarchar(255)='',
	@materialCode	nvarchar(255)='',
	@colorCode		nvarchar(255)='',
	@stepId			nvarchar(150)='',	
	@weightRecycle	float,
	@lostType		nvarchar(100)='',	
	@mixRawId		int,
	@machineID		nvarchar(100)='',
	@qrCode			nvarchar(100)=''
AS
BEGIN
	INSERT INTO CrushRaw(ShiftName,  
                         OperatorName,  
                         ProductName,  
                         MaterialName,  
                         ColorName,
					     StepName,
					     WeightRecycle,
					     LossTypeName,					     
					     MixRawId,
						 MachineName,
					     RecycledID,
					     CreateTime)  
			VALUES	  (@shiftID,
					   @operatorCode,
					   @productCode,
					   @materialCode,
					   @colorCode,
					   @stepId,
					   @weightRecycle,
					   @lostType,
					   @mixRawId,
					   @machineID,
					   @qrCode,
					   SYSDATETIME())
END


GO
/****** Object:  StoredProcedure [dbo].[sp_createMixOut]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_createMixOut] 
	-- Add the parameters for the stored procedure here
	@weightRunner	 float,
	@weightDefect	 float,
	@weightBlackDot	 float,
	@weightContaminated	float,
	@weightRecycle		float,
	@weightCookie	float,
	@mixRawId	int
AS
BEGIN
	

    -- Insert statements for procedure here
	INSERT INTO MixingOut(
							WeightRunner,
							WeightDefect,
							WeightBlackDot,
							WeighContamination,
							WeightRecycle,
							WeightCookie,
							MixRawId,
							CreateTime)
	VALUES (@weightRunner, @weightDefect, @weightBlackDot, @weightContaminated, @weightRecycle, @weightCookie, @mixRawId, SYSDATETIME())

			
END

GO
/****** Object:  StoredProcedure [dbo].[sp_createMixRaw]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Name :       sp_createMixRaw
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Insert a new Mixraw>
-- =============================================
CREATE PROCEDURE [dbo].[sp_createMixRaw] 
	-- Add the parameters for the stored procedure here
	@shiftID		nvarchar(50)='',
	@operatorCode	nvarchar(100)='',
	@productCode	nvarchar(255)='',
	@materialCode	nvarchar(255)='',
	@colorCode		nvarchar(255)='',
	@stepId			nvarchar(150)='',	
	@weightRecycle	float,
	@weightMaterial float,
	@totalMaterial	float,
	@machineID		nvarchar(100)='',
	@crushRawId		int,
	@qrCode			nvarchar(100)=''
AS
BEGIN
	INSERT INTO MixRaw(ShiftName,  
                       OperatorName,  
                       ProductName,  
                       MaterialName,  
                       ColorName,
					   StepName,
					   WeightRecycle,
					   WeightMaterial,
					   TotalMaterial,
					   MachineName,
					   CrushRawID,
					   MixBacode,					   
					   CreateTime)  
			VALUES	  (@shiftID,
					   @operatorCode,
					   @productCode,
					   @materialCode,
					   @colorCode,
					   @stepId,
					   @weightRecycle,
					   @weightMaterial,
					   @totalMaterial,
					   @machineID,
					   @crushRawId,
					   @qrCode,
					   SYSDATETIME())
END

GO
/****** Object:  StoredProcedure [dbo].[sp_deleteMixRaw]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Name :       sp_deleteMixRaw
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Delete a Mixraw>
-- =============================================
CREATE PROCEDURE [dbo].[sp_deleteMixRaw] 
	-- Add the parameters for the stored procedure here
	@mixRawId		int	
AS
BEGIN
	DELETE FROM MixRaw	
	WHERE 
			MixRawId = @mixRawId 	
END

GO
/****** Object:  StoredProcedure [dbo].[sp_editCrushRaw]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Name :       sp_createCrushRaw
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Insert a new Crushraw>
-- =============================================
CREATE PROCEDURE [dbo].[sp_editCrushRaw] 
	-- Add the parameters for the stored procedure here
	@crushRawId		int,
	@shiftID		nvarchar(50)='',
	@operatorCode	nvarchar(100)='',
	@productCode	nvarchar(255)='',
	@materialCode	nvarchar(255)='',
	@colorCode		nvarchar(255)='',
	@stepId			nvarchar(150)='',	
	@weightRecycle	float,
	@lostType		nvarchar(100)='',	
	@mixRawId		int,
	@machineID		nvarchar(100)=''
	
AS
BEGIN
	UPDATE CrushRaw
	SET
		ShiftName=@shiftID,  
		OperatorName=@operatorCode,  
        ProductName=@productCode,  
        MaterialName=@materialCode,  
        ColorName=@colorCode,
		StepName=@stepId,
		WeightRecycle=@weightRecycle,
		LossTypeName=@lostType,					     
		MixRawId=@mixRawId,
		MachineName=@machineID
		
	WHERE
		CrushRawId = @crushRawId
END


GO
/****** Object:  StoredProcedure [dbo].[sp_editMixRaw]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Name :       sp_editMixRaw
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Edit a Mixraw>
-- =============================================
CREATE PROCEDURE [dbo].[sp_editMixRaw] 
	-- Add the parameters for the stored procedure here
	@mixRawId		int,
	@shiftID		nvarchar(50)='',
	@operatorCode	nvarchar(100)='',
	@productCode	nvarchar(255)='',
	@materialCode	nvarchar(255)='',
	@colorCode		nvarchar(255)='',
	@stepId			nvarchar(150)='',	
	@weightRecycle	float,
	@weightMaterial float,
	@totalMaterial	float,
	@machineID		nvarchar(100)='',
	@crushRawId		int,
	@qrCode			nvarchar(100)=''
AS
BEGIN
	UPDATE MixRaw
	SET
			ShiftName		= @shiftID,
			OperatorName	= @operatorCode,
			ProductName		= @productCode,
			MaterialName	= @materialCode,
			ColorName		= @colorCode,
			StepName		= @stepId,
			WeightRecycle	= @weightRecycle,
			WeightMaterial	= @weightMaterial,
			TotalMaterial	= @totalMaterial,
			MachineName		= @machineID,
			CrushRawID		= @crushRawId,			
			MixBacode		= @qrCode
	WHERE 
			MixRawId = @mixRawId 	
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getColor]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Thi.Vu>
-- Create date: <20200228>
-- Description:	<Get a Color line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getColor]
	-- Add the parameters for the stored procedure here	
	@colorCode varchar(50)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *
	FROM Color WITH (NOLOCK)
	WHERE ColorCode = @colorCode
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getColors]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Thi.Vu>
-- Create date: <20200228>
-- Description:	<Get Color lines>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getColors]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *
	FROM Color WITH (NOLOCK)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getColorsProduct]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Thi.Vu>
-- Create date: <20200228>
-- Description:	<Get ColorCode and ColorName from a ProductId>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getColorsProduct]
	-- Add the parameters for the stored procedure here	
	@ProductId varchar(100)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT pc.ProductCode, pc.ColorCode, c.ColorName
	FROM Color c WITH (NOLOCK) LEFT JOIN ProductColor pc WITH (NOLOCK) ON c.ColorCode = pc.ColorCode
	WHERE pc.ProductCode = @ProductId
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getColorsProducts]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getColorsProducts]
	-- Add the parameters for the stored procedure here		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT pc.*, c.ColorName
	FROM  ProductColor pc, Color c
	WHERE PC.ColorCode = C.ColorCode
	
END
GO
/****** Object:  StoredProcedure [dbo].[sp_getCrushRaw]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Name :       sp_getCrushRaw
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Get all CrushRaw line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getCrushRaw] 
	-- Add the parameters for the stored procedure here
	@crushRawID	int	
AS
BEGIN
	SELECT * FROM CrushRaw (NOLOCK)		
	WHERE CrushRawId = @crushRawID
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getCrushRaws]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Name :       sp_getCrushRaws
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Get all Mixraw line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getCrushRaws] 
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	SELECT * FROM CrushRaw		
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getFullCrushRaw]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Name :       sp_getCrushRaw
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Get all CrushRaw line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getFullCrushRaw] 
	-- Add the parameters for the stored procedure here
	@crushRawID	int	
AS
BEGIN
	SELECT 
		cr.CrushRawId,
		cr.ShiftName,
		cr.OperatorName OperatorCode,
		op.OperatorName,
		cr.ProductName ProductCode,
		pr.ProductName,
		cr.MaterialName MaterialCode,
		ma.MaterialName,
		cr.ColorName ColorCode,
		co.ColorName,
		cr.StepName,
		cr.WeightRecycle,
		cr.LossTypeName,
		cr.MixRawId,
		mr.MixBacode,
		cr.MachineName,
		cr.CreateBy,
		cr.CreateTime,
		cr.RecycledID,
		cr.Posted 
	FROM CrushRaw cr, Color co, Operator op, Materials ma, Product pr, MixRaw mr
	WHERE
		cr.ColorName = co.ColorCode and
		cr.OperatorName = op.OperatorCode and
		cr.MaterialName = ma.MaterialCode and
		cr.ProductName = pr.ProductCode and
		cr.MixRawId = mr.MixRawId and		
	    cr.CrushRawId = @crushRawID
END


GO
/****** Object:  StoredProcedure [dbo].[sp_getFullCrushRaws]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Name :       sp_getCrushRaws
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Get all Mixraw line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getFullCrushRaws] 
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	SELECT 
		cr.CrushRawId,
		cr.ShiftName,
		cr.OperatorName OperatorCode,
		op.OperatorName,
		cr.ProductName ProductCode,
		pr.ProductName,
		cr.MaterialName MaterialCode,
		ma.MaterialName,
		cr.ColorName ColorCode,
		co.ColorName,
		cr.StepName,
		cr.WeightRecycle,
		cr.LossTypeName,
		cr.MixRawId,
		mr.MixBacode,
		cr.MachineName,
		cr.CreateBy,
		cr.CreateTime,
		cr.RecycledID,
		cr.Posted 
	FROM CrushRaw cr, Color co, Operator op, Materials ma, Product pr, MixRaw mr
	WHERE
		cr.ColorName = co.ColorCode and
		cr.OperatorName = op.OperatorCode and
		cr.MaterialName = ma.MaterialCode and
		cr.ProductName = pr.ProductCode and
		cr.MixRawId = mr.MixRawId
END


GO
/****** Object:  StoredProcedure [dbo].[sp_getFullMixOut]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Name :       sp_getMixRaws
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Get all Mixraw line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getFullMixOut] 
	-- Add the parameters for the stored procedure here	
	@mixOutId int	
AS
BEGIN
	SELECT 
		mo.Id,
		mo.WeightRunner,
		mo.WeightDefect,
		mo.WeightBlackDot,
		mo.WeighContamination,
		mo.WeightRecycle,
		mo.WeightCookie,
		mo.MixRawId,
		mi.MixBacode,
		mo.CreateTime,		
		mo.Posted 
	FROM MixingOut mo, MixRaw mi
	Where 
		mo.MixRawId = mi.MixRawId and mo.Id = @mixOutId
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getFullMixOuts]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Name :       sp_getMixRaws
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Get all Mixraw line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getFullMixOuts] 
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	SELECT 
		mo.Id,
		mo.CreateTime,	
		mo.MixRawId,
		mi.MixBacode,	
		mo.WeightRunner,
		mo.WeightDefect,
		mo.WeightBlackDot,
		mo.WeighContamination,
		mo.WeightRecycle,
		mo.WeightCookie,				
		mo.Posted 
	FROM MixingOut mo, MixRaw mi
	Where 
		mo.MixRawId = mi.MixRawId
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getFullMixRaw]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Name :       sp_getMixRaws
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Get all Mixraw line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getFullMixRaw] 
	-- Add the parameters for the stored procedure here	
	@mixRawID	int
AS
BEGIN
	SELECT 
		mi.MixRawId,
		mi.ShiftName, 
		mi.OperatorName OperatorCode,
		op.OperatorName,
		mi.ProductName ProductCode, 
		pr.ProductName, 
		mi.MaterialName MaterialCode, 
		ma.MaterialName,
		mi.ColorName ColorCode, 
		co.ColorName, 
		mi.StepName StepCode,
		st.StepName,
		mi.WeightRecycle,
		mi.WeightMaterial,		
		mi.TotalMaterial,
		mi.MachineName,		
		mi.MixBacode,
		mi.CreateTime,
		mi.CrushRawID,
		mi.Posted 
	FROM MixRaw mi, Color co, Operator op, Materials ma, Product pr, Step st
	Where 
		mi.ColorName = co.ColorCode and 
		mi.OperatorName = op.OperatorCode and
		mi.MaterialName = ma.MaterialCode and
		mi.ProductName = pr.ProductCode and
		mi.StepName = st.StepCode and
		mi.MixRawId = @mixRawID
END



GO
/****** Object:  StoredProcedure [dbo].[sp_getFullMixRaws]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Name :       sp_getMixRaws
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Get all Mixraw line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getFullMixRaws] 
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	SELECT 
		mi.MixRawId,
		mi.ShiftName, 
		mi.OperatorName OperatorCode,
		op.OperatorName,
		mi.ProductName ProductCode, 
		pr.ProductName, 
		mi.MaterialName MaterialCode, 
		ma.MaterialName,
		mi.ColorName ColorCode, 
		co.ColorName, 
		mi.StepName StepCode,
		st.StepName,
		mi.WeightRecycle,
		mi.WeightMaterial,		
		mi.TotalMaterial,
		mi.MachineName,		
		mi.MixBacode,
		mi.CreateTime,
		mi.CrushRawID,
		cr.RecycledID,
		mi.Posted 
	FROM MixRaw mi Left Join CrushRaw cr on mi.CrushRawID = cr.CrushRawId, Color co, Operator op, Materials ma, Product pr, Step st
	Where 
		mi.ColorName = co.ColorCode and 
		mi.OperatorName = op.OperatorCode and
		mi.MaterialName = ma.MaterialCode and
		mi.ProductName = pr.ProductCode and
		mi.StepName = st.StepCode 
END


GO
/****** Object:  StoredProcedure [dbo].[sp_getLastIdentity]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Thi Vu>
-- Create date: <20200305>
-- Description:	<Get current Identity of CrushRaw>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getLastIdentity] 
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @LastIdentity INTEGER
	SET @LastIdentity = (SELECT IDENT_CURRENT ('CrushRaw'));
	RETURN @LastIdentity
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getLastMixIdentity]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Thi Vu>
-- Create date: <20200305>
-- Description:	<Get current Identity of CrushRaw>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getLastMixIdentity] 
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @LastIdentity INTEGER
	SET @LastIdentity = (SELECT IDENT_CURRENT ('MixRaw'));
	RETURN @LastIdentity
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getMaterial]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Thi.Vu>
-- Create date: <20200228>
-- Description:	<Get a Material line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getMaterial]
	-- Add the parameters for the stored procedure here	
	@materialCode varchar(50)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *
	FROM Materials WITH (NOLOCK)
	WHERE MaterialCode = @materialCode
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getMaterials]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Thi.Vu>
-- Create date: <20200228>
-- Description:	<Get Material lines>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getMaterials]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *
	FROM Materials WITH (NOLOCK)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getMixRaw]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Name :       sp_getaMixRaw
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Get a Mixraw line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getMixRaw] 
	-- Add the parameters for the stored procedure here
	@mixRawId		int	
AS
BEGIN
	SELECT * FROM MixRaw
	WHERE 
			MixRawId = @mixRawId 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getMixRaws]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Name :       sp_getMixRaws
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Get all Mixraw line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getMixRaws] 
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	SELECT * FROM MixRaw		
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getOperator]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Thi.Vu>
-- Create date: <20200228>
-- Description:	<Get a Operator line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getOperator]
	-- Add the parameters for the stored procedure here	
	@operatorCode varchar(50)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *
	FROM Operator WITH (NOLOCK)
	WHERE OperatorCode = @operatorCode
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getOperators]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Thi.Vu>
-- Create date: <20200228>
-- Description:	<Get Operator lines>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getOperators]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *
	FROM Operator WITH (NOLOCK)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getProduct]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Thi.Vu>
-- Create date: <20200228>
-- Description:	<Get a Product line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getProduct]
	-- Add the parameters for the stored procedure here	
	@productCode varchar(50)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *
	FROM Product WITH (NOLOCK)
	WHERE ProductCode = @productCode
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getProducts]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Thi.Vu>
-- Create date: <20200228>
-- Description:	<Get Product lines>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getProducts]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *
	FROM Product WITH (NOLOCK)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getStep]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Thi.Vu>
-- Create date: <20200228>
-- Description:	<Get a Step line>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getStep]
	-- Add the parameters for the stored procedure here	
	@stepCode varchar(50)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *
	FROM Step WITH (NOLOCK)
	WHERE StepCode = @stepCode
END

GO
/****** Object:  StoredProcedure [dbo].[sp_getSteps]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Thi.Vu>
-- Create date: <20200228>
-- Description:	<Get Step lines>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getSteps]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *
	FROM Step WITH (NOLOCK)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_scanCOMPOUND]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[sp_scanCOMPOUND]
@TrackType varchar(10)='', 
@Barcode varchar(100)='', --[sp_scanCOMPOUND] 'COMPOUND','PF-57377-CP',1
@ScaleWeight numeric(6,1)=0
as




--ĐÙN (COMPOUND)
IF @TrackType='COMPOUND'
BEGIN 
		if LEFT(@Barcode,2)<>'PF' OR RIGHT(@Barcode,2)<>'CP'
		BEGIN
			select N'Barcode phải từ Chị Lan In Ra và PHẢI có Đùn!' as Msg
			return
		END

		if not exists(select VoucherId from SSBC_MixVouchers WHERE VoucherId=SUBSTRING(@Barcode,4,LEN(@Barcode)-6))
		begin
			select N'Liên Hệ chị Lan lưu lại phiếu trộn!' as Msg
			return
		end

		Declare @year varchar(4)
		Declare @Seq int
		Declare @TrackNo varchar(50)=''
		Declare @ScaleWeightCompare numeric(6,1)
		

		Declare @Total_BatchQty numeric(6,1)
		Declare @Max_BatchNo int
		Declare @CountLabel int
		
		
		Set @year=year(Getdate())

		select @TrackNo=isnull('CP'+right(@year,2)+ right('00000'+CONVERT(varchar(10),Max(Seq)+1),6),'CP'+right(@year,2)+'000001'),
		@Seq=ISNULL(Max(Seq)+1,1) from SSBC_Compound_Trackings where year(ScaleDate)=@year
		-----------------------
		
		
		set @ScaleWeightCompare=Isnull((select ScaleWeight from SSBC_Compound_Trackings where year(ScaleDate)=@year and Seq=(@Seq-1)),0)


		if(@ScaleWeightCompare<>@ScaleWeight)
		begin
			set @Max_BatchNo=Isnull((select max(BatchNo) from SSBC_Compound_Trackings where ProForBacode=@Barcode),1)
			SET @Total_BatchQty=Isnull((select sum(ScaleWeight) from SSBC_Compound_Trackings where ProForBacode=@Barcode),0)
			set @CountLabel=Isnull((select count(ProForBacode) from SSBC_Compound_Trackings where ProForBacode=@Barcode),0)--=@Total_BatchQty

			--Insert---------------------
			insert into SSBC_Compound_Trackings(TrackNo,Seq,ColorCode,ScaleWeight,ScaleDate,ProForBacode,BatchNo)
			select @TrackNo,@Seq,ColorCo,@ScaleWeight,getdate(),@Barcode,case when @Total_BatchQty+@ScaleWeight<=(TotalQty /BatchNo) then @Max_BatchNo else @Max_BatchNo+1 end
			from SSBC_MixVouchers WHERE VoucherId=SUBSTRING(@Barcode,4,LEN(@Barcode)-6) 
			-----------------------
			select '' Msg,TrackNo,WinlineName,ColorCode,ColorName,MaterialCo,MaterialName,ScaleWeight,ScaleDate,BatchNo,@CountLabel as CountLabel,MachineInfo
			from vSSBC_CompoundTracks
			where TrackNo=@TrackNo
		end
		ELSE
		BEGIN
			select N'Kiểm tra lại dữ liệu!' as Msg
		END

END
ELSE
BEGIN
	select N'Kiểm tra lại dữ liệu!' as Msg
END






GO
/****** Object:  StoredProcedure [dbo].[sp_scanCOPY]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---[sp_scanCOPY] 'MI19012448-MI'

CREATE Proc [dbo].[sp_scanCOPY] 
@Barcode varchar(100)=''
as

--

Declare @year varchar(4)
declare @Seq int
Declare @TrackNo varchar(50)=''
--
Set @year=year(Getdate())



 
 

--'PF-573737-CP'
If LEFT(@Barcode,2)='MI'
Begin
	select @TrackNo=SUBSTRING(@Barcode,1,len(@Barcode)-3)

	if exists(select TrackNo from SSBC_Mix_Trackings WHERE TrackNo=@TrackNo)
	begin
		select '' Msg,TrackNo,WinlineName,ColorCode,ColorName,MaterialCo,MaterialName,ScaleWeight,getdate() as ScaleDate,BatchNo,BatchNo as CountLabel,@Barcode AS fBarcode--,MachineInfo
		from vSSBC_MixTracks
		where TrackNo=@TrackNo
		

	end
	else
	begin
		select N'Barcode này không tồn tại!' as Msg
	end


End
ELSE
--CR00000-CP


If LEFT(@Barcode,2)='CR'
Begin
	select @TrackNo=SUBSTRING(@Barcode,1,len(@Barcode)-3)

	if exists(select TrackNo from SSBC_Mix_Trackings WHERE TrackNo=@TrackNo)
	begin
		select '' Msg,TrackNo,ColorCode,ColorName, MaterialCo,ScaleWeight,getdate() as ScaleDate,@Barcode AS fBarcode from vSSBC_WhsTracks WHERE TrackNo=@Barcode

	end
	else
	begin
		select N'Barcode này không tồn tại!' as Msg
	end



end



GO
/****** Object:  StoredProcedure [dbo].[sp_scanCRUSH]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---MI19000001-RU,MI19000001-DE
create Proc [dbo].[sp_scanCRUSH] 
@Barcode varchar(100)='', --sp_MixStation_GetData 'PF-57377-CP'
@ScaleWeight numeric(6,1)=0
as

--
--SELECT * FROM SSBC_Crush_Trackings




Declare @year varchar(4)
declare @Seq int
Declare @TrackNo varchar(50)=''
Declare @ColorCo int=0
--
Set @year=year(Getdate())



 
If LEFT(@Barcode,2)<>'MI'
BEGIN
	select N'Barcode phải là từ trạm Mix !' as Msg
END
ELSE IF LEFT(@Barcode,2)='MI' and right(@Barcode,2)<>'DE' and right(@Barcode,2)<>'RU'
BEGIN
	select N'Barcode phải là Runner(RU) hoặc Defect(DE) !' as Msg
END
ELSE
BEGIN
		set @ColorCo=(select top 1 ColorCode from SSBC_Mix_Trackings where TrackNo=substring(@Barcode,1,len(@Barcode)-3))

		select @TrackNo=isnull('CR'+right(@year,2)+ right('00000'+CONVERT(varchar(10),Max(Seq)+1),6),'CR'+right(@year,2)+'000001')+'-'+right(@Barcode,2),
		@Seq=ISNULL(Max(Seq)+1,1) from SSBC_Crush_Trackings where year(ScaleDate)=@year
		-----
		insert into SSBC_Crush_Trackings(TrackNo,Seq,ColorCode,ScaleWeight,ScaleDate,ParentTrackNo)
		values(@TrackNo,@Seq,@ColorCo,@ScaleWeight,GETDATE(),substring(@Barcode,1,len(@Barcode)-3))
		
		select '' Msg,TrackNo,ColorCode,ColorName, MaterialCo, MaterialName,'RE' MaterialType,ScaleWeight,ScaleDate from vSSBC_CrushTracks WHERE TrackNo=@TrackNo
END




GO
/****** Object:  StoredProcedure [dbo].[sp_scanMix]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[sp_scanMix]
@TrackType varchar(10)='', 
@Barcode varchar(100)='', --[sp_scanMix] 'MIX','PF-57516-RE',0
@ScaleWeight numeric(6,1)=0,
@Reason nvarchar(150)=''
as



--Trộn (COMPOUND)
IF @TrackType='MIX'
BEGIN 
		if LEFT(@Barcode,2)<>'PF' OR RIGHT(@Barcode,2)<>'RE'
		BEGIN
			select N'Barcode phải từ Chị Lan In Ra và Không có Đùn!' as Msg
			return
		END

		if not exists(select VoucherId from SSBC_MixVouchers WHERE VoucherId=SUBSTRING(@Barcode,4,LEN(@Barcode)-6))
		begin
			select N'Liên Hệ chị Lan lưu lại phiếu trộn!' as Msg
			return
		end

		Declare @year varchar(4)
		Declare @Seq int
		Declare @TrackNo varchar(50)=''
		Declare @ScaleWeightCompare numeric(6,1)
		

		Declare @Total_BatchQty numeric(6,1)
		Declare @Max_BatchNo int
		Declare @CountLabel int
		
		
		Set @year=year(Getdate())

		select @TrackNo=isnull('MI'+right(@year,2)+ right('00000'+CONVERT(varchar(10),Max(Seq)+1),6),'MI'+right(@year,2)+'000001'),
		@Seq=ISNULL(Max(Seq)+1,1) from SSBC_Mix_Trackings where year(ScaleDate)=@year
		-----------------------
		if @Reason<>''
		begin
			insert into SSBC_OverWeight select @Barcode+'-'+CONVERT(varchar(10),isnull(Max(Seq),0)+1),
												@Barcode,
												isnull(Max(Seq),0)+1,
												@Reason,GETDATE()
												from SSBC_OverWeight where ProForBacode=@Barcode
		end

		
		set @ScaleWeightCompare=Isnull((select ScaleWeight from SSBC_Mix_Trackings where year(ScaleDate)=@year and Seq=(@Seq-1)),0)


		if(@ScaleWeightCompare<>@ScaleWeight)
		begin
			set @Max_BatchNo=Isnull((select max(BatchNo) from SSBC_Mix_Trackings where ProForBacode=@Barcode),1)
			SET @Total_BatchQty=Isnull((select sum(ScaleWeight) from SSBC_Mix_Trackings where ProForBacode=@Barcode),0)
			set @CountLabel=Isnull((select count(ProForBacode) from SSBC_Mix_Trackings where ProForBacode=@Barcode),0)--=@Total_BatchQty

			--Insert---------------------
			insert into SSBC_Mix_Trackings(TrackNo,Seq,ColorCode,ScaleWeight,ScaleDate,ProForBacode,BatchNo)
			select @TrackNo,@Seq,ColorCo,@ScaleWeight,getdate(),@Barcode,case when @Total_BatchQty+@ScaleWeight<=(TotalQty /BatchNo) then @Max_BatchNo else @Max_BatchNo+1 end
			from SSBC_MixVouchers WHERE VoucherId=SUBSTRING(@Barcode,4,LEN(@Barcode)-6) 

			---
			update a
			set a.OverWeightId=b.OverWeightId
			from SSBC_Mix_Trackings a
			inner join (select top 1 OverWeightId,ProForBacode from SSBC_OverWeight where ProForBacode=@Barcode order by Seq desc) b
			on a.ProForBacode=b.ProForBacode
			where a.TrackNo=@TrackNo
			-----------------------
			select '' Msg,TrackNo,WinlineName,ColorCode,ColorName,MaterialCo,MaterialName,ScaleWeight,ScaleDate,BatchNo,@CountLabel as CountLabel,MachineInfo
			from vSSBC_MixTracks
			where TrackNo=@TrackNo
		end
		else
		begin
			select N'Kiểm tra lại dữ liệu!' as Msg
		end

END
ELSE
BEGIN
	select N'Kiểm tra lại dữ liệu!' as Msg
END



GO
/****** Object:  StoredProcedure [dbo].[sp_scanProReturn]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[sp_scanProReturn]
@TrackType varchar(10)='', 
@Barcode varchar(100)='', --[sp_scanProReturn] 'CsOMPOUND','PF-57377-CP',1
@ScaleWeight numeric(6,1)=0
as




--TRẢ NHỰA
IF @TrackType='RETURN'
BEGIN 
		if LEFT(@Barcode,2)<>'MI' OR RIGHT(@Barcode,2)<>'MI'
		BEGIN
			select N'Barcode phải là Trộn (MI)!' as Msg
			return
		END

		if not exists(select TrackNo from SSBC_Mix_Trackings WHERE TrackNo=substring(@Barcode,1,len(@Barcode)-3))
		begin
			select N'Tem không tồn tại. Liên hệ IT kiểm tra!' as Msg
			return
		end

		Declare @year varchar(4)
		Declare @Seq int
		Declare @TrackNo varchar(50)=''
		
		
		Set @year=year(Getdate())

		select @TrackNo=isnull('RE'+right(@year,2)+ right('00000000'+CONVERT(varchar(10),Max(Seq)+1),8),'RE'+right(@year,2)+'00000001'),
		@Seq=ISNULL(Max(Seq)+1,1) from SSBC_ProReturn_Trackings where year(ScaleDate)=@year
		-----
		insert into SSBC_ProReturn_Trackings(TrackNo,Seq,ColorCode,ScaleWeight,ScaleDate,ParentTrackNo)
		select @TrackNo,@Seq,ColorCode,@ScaleWeight,gETDATE(),substring(@Barcode,1,len(@Barcode)-3) from SSBC_Mix_Trackings where TrackNo=substring(@Barcode,1,len(@Barcode)-3)
		 
		
		select '' Msg,TrackNo,WinlineName,ColorCode,ColorName,MaterialCo,MaterialName,'RE' as MaterialType,ScaleWeight,ScaleDate,isnull(BatchNo,0) BatchNo,'' MachineInfo
		from vSSBC_ProReturnTracks
		where TrackNo=@TrackNo

	

END
ELSE
BEGIN
	select N'Kiểm tra lại dữ liệu!' as Msg
END

--select * from vSSBC_MixTracks



GO
/****** Object:  StoredProcedure [dbo].[sp_scanProReturnOut]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[sp_scanProReturnOut]
@TrackType varchar(10)='', 
@Barcode varchar(100)='', --[sp_scanProReturnOut] 'CsOMPOUND','PF-57377-CP',1
@ScaleWeight numeric(6,1)=0,
@voucherAfter int=0
as



--XUẤT NHỰA THU HỒI
IF @TrackType='RETURN-OUT'
BEGIN 
		if LEFT(@Barcode,2)<>'RE' 
		BEGIN
			select N'Barcode phải là Nhựa đã thu hồi!' as Msg
			return
		END

		if not exists(select TrackNo from SSBC_ProReturn_Trackings WHERE TrackNo=@Barcode)--substring(@Barcode,1,len(@Barcode)-3))
		begin
			select N'Tem không tồn tại. Liên hệ IT kiểm tra!' as Msg
			return
		end

		Declare @year varchar(4)
		Declare @Seq int
		Declare @TrackNo varchar(50)=''
		
		
		Set @year=year(Getdate())

		select @TrackNo=isnull('RO'+right(@year,2)+ right('00000000'+CONVERT(varchar(10),Max(Seq)+1),8),'RO'+right(@year,2)+'00000001'),
		@Seq=ISNULL(Max(Seq)+1,1) from SSBC_ProReturnOut_Trackings where year(ScaleDate)=@year
		-----
		insert into SSBC_ProReturnOut_Trackings(TrackNo,Seq,ColorCode,ScaleWeight,ScaleDate,ParentTrackNo,VoucherAfter,ColorCodeAfter)
		select @TrackNo,@Seq,ColorCode,@ScaleWeight,gETDATE(),@Barcode,@voucherAfter,0 from vSSBC_ProReturnTracks where TrackNo=@Barcode

		if @voucherAfter<>0
		begin
			update a set a.ColorCodeAfter=b.ColorCo
			from SSBC_ProReturnOut_Trackings a
			inner join SSBC_MixVouchers b on a.VoucherAfter=b.VoucherId
			where b.VoucherId=@voucherAfter and a.TrackNo=@Barcode

		end
		
		select '' Msg,TrackNo,WinlineName,ColorCode,ColorName,MaterialCo,MaterialName,'RE' AS MaterialType,ScaleWeight,ScaleDate,0 AS BatchNo,'' MachineInfo
		from vSSBC_ProReturnOutTracks
		where TrackNo=@TrackNo

END
ELSE
BEGIN
	select N'Kiểm tra lại dữ liệu!' as Msg
END




GO
/****** Object:  StoredProcedure [dbo].[sp_scanRED]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---MI19000001-RU,MI19000001-DE
CREATE Proc [dbo].[sp_scanRED] 
@Barcode varchar(100)='', --sp_scanRE 'PF-57377-CP'
@ScaleWeight numeric(6,1)=0
as

--
--SELECT * FROM SSBC_Crush_Trackings




Declare @year varchar(4)
declare @Seq int
Declare @TrackNo varchar(50)=''
Declare @ColorCo int=0
--
Set @year=year(Getdate())





 
If LEFT(@Barcode,2)<>'MI'
BEGIN
	select N'Barcode phải là từ trạm Mix !' as Msg
END
ELSE IF LEFT(@Barcode,2)='MI' and right(@Barcode,2)<>'RE' and right(@Barcode,2)<>'DE'
BEGIN
	select N'Barcode phải là RED(RE) hoặc Defect(DE)!' as Msg
END
ELSE
BEGIN
		set @ColorCo=(select top 1 ColorCode from SSBC_Mix_Trackings where TrackNo=substring(@Barcode,1,len(@Barcode)-3))

		select @TrackNo=isnull('RE'+right(@year,2)+ right('00000'+CONVERT(varchar(10),Max(Seq)+1),6),'CR'+right(@year,2)+'000001')+'-'+right(@Barcode,2),
		@Seq=ISNULL(Max(Seq)+1,1) from SSBC_Red_Trackings where year(ScaleDate)=@year
		-----
		insert into SSBC_Red_Trackings(TrackNo,Seq,ColorCode,ScaleWeight,ScaleDate,ParentTrackNo)
		values(@TrackNo,@Seq,@ColorCo,@ScaleWeight,GETDATE(),substring(@Barcode,1,len(@Barcode)-3))
		
		select '' Msg,TrackNo,ColorCode,ColorName, MaterialCo, MaterialName,'RE' MaterialType,ScaleWeight,ScaleDate from vSSBC_RedTracks WHERE TrackNo=@TrackNo
END





GO
/****** Object:  StoredProcedure [dbo].[sp_scanWHS]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[sp_scanWHS] 
@Barcode varchar(100)='', --sp_scanWHS 'PF-58451-RE',0
@ScaleWeight numeric(6,1)=0
as

--

Declare @year varchar(4)
declare @Seq int
Declare @TrackNo varchar(50)=''
Declare @ColorCo int=0
--
Set @year=year(Getdate())

declare @ScaleWeightCompare numeric(6,1)

 
IF  LEFT(@Barcode,2)<>'CR' AND  LEFT(@Barcode,2)<>'CP'
BEGIN
	select N'Barcode không hợp lệ!' as Msg
	RETURN
END
 
-------------------------------
select @TrackNo=isnull('WH'+right(@year,2)+ right('00000'+CONVERT(varchar(10),Max(Seq)+1),6),'WH'+right(@year,2)+'000001'),
		@Seq=ISNULL(Max(Seq)+1,1) from SSBC_WHS_Trackings where year(ScaleDate)=@year
		-----
		
--------------------------------
If LEFT(@Barcode,2)='CR'
Begin
		set @ColorCo=(select top 1 ColorCode from vSSBC_CrushTracks where TrackNo=@Barcode)


End

else If LEFT(@Barcode,2)='CP'
Begin
		
		set @ColorCo=(select top 1 ColorCode from SSBC_Compound_Trackings where TrackNo=@Barcode)

End



insert into SSBC_WHS_Trackings(TrackNo,Seq,ColorCode,ScaleWeight,ScaleDate,ParentTrackNo) 
values(@TrackNo,@Seq,@ColorCo,@ScaleWeight,GETDATE(),@Barcode)


select '' Msg,TrackNo,ColorCode,ColorName, MaterialCo,MaterialName,LEFT(@Barcode,2) AS MaterialType,ScaleWeight,ScaleDate from vSSBC_WhsTracks

WHERE TrackNo=@TrackNo





GO
/****** Object:  StoredProcedure [dbo].[sp_setCrushPosted]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Thi Vu>
-- Create date: <20200306>
-- Description:	<Set Posted>
-- =============================================
CREATE PROCEDURE [dbo].[sp_setCrushPosted]
	-- Add the parameters for the stored procedure here
	@crushRawId		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE CrushRaw
	SET Posted = 1
	WHERE CrushRawId = @crushRawId 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_setMixOutPosted]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Thi Vu>
-- Create date: <20200306>
-- Description:	<Set Posted>
-- =============================================
CREATE PROCEDURE [dbo].[sp_setMixOutPosted]
	-- Add the parameters for the stored procedure here
	@Id		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE MixingOut
	SET Posted = 1
	WHERE Id = @Id
END


GO
/****** Object:  StoredProcedure [dbo].[sp_setPosted]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Thi Vu>
-- Create date: <20200306>
-- Description:	<Set Posted>
-- =============================================
CREATE PROCEDURE [dbo].[sp_setPosted]
	-- Add the parameters for the stored procedure here
	@mixRawId		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE MixRaw
	SET Posted = 1
	WHERE MixRawId = @mixRawId 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SSBC_Delete_Trackings]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[sp_SSBC_Delete_Trackings] 
@TrackType varchar(10)='',
@Barcode varchar(100)=''
as


If @TrackType='COMPOUND'
BEGIN
	Delete from SSBC_Compound_Trackings where TrackNo=@Barcode
	Select N'Đã Xóa ĐÙN Thành Công !' as Msg
	return

END

If @TrackType='MIX'
BEGIN
	Delete from SSBC_Mix_Trackings where TrackNo=@Barcode
	Select N'Đã Xóa TRỘN Thành Công !' as Msg
	return

END

If @TrackType='CRUSH'
BEGIN
	Delete from SSBC_Crush_Trackings where TrackNo=@Barcode
	Select N'Đã Xóa XAY Thành Công !' as Msg
	return

END

If @TrackType='RED'
BEGIN
	Delete from SSBC_Red_Trackings where TrackNo=@Barcode
	Select N'Đã Xóa CHẤM ĐEN Thành Công !' as Msg
	return

END

If @TrackType='WHS'
BEGIN
	Delete from SSBC_WHS_Trackings where TrackNo=@Barcode
	Select N'Đã Xóa CHUYỂN KHO Thành Công !' as Msg
	return

END

If @TrackType='RETURN'
BEGIN
	Delete from SSBC_ProReturn_Trackings where TrackNo=@Barcode
	Select N'Đã Xóa NHỰA THU HỒI Thành Công !' as Msg
	return

END

If @TrackType='RETURN-OUT'
BEGIN
	Delete from SSBC_ProReturnOut_Trackings where TrackNo=@Barcode
	Select N'Đã Xóa XUẤT NHỰA THU HỒI Thành Công !' as Msg
	return

END



GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateMixingOut]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Name :       sp_createCrushRaw
-- Author:		<Thi.Vu>
-- Create date: <20200303>
-- Description:	<Insert a new Crushraw>
-- =============================================
CREATE PROCEDURE [dbo].[sp_UpdateMixingOut] 
	-- Add the parameters for the stored procedure here
	@weightRunner	 float,
	@weightDefect	 float,
	@weightBlackDot	 float,
	@weightContaminated	float,
	@weightRecycle		float,
	@weightCookie	float,
	@mixRawId	int,
	@Id			int
AS
BEGIN
	UPDATE MixingOut
	SET
		WeightRunner=@weightRunner,  
		WeightDefect=@weightDefect,  
        WeightBlackDot=@weightBlackDot,  
        WeighContamination=@weightContaminated,  
        WeightRecycle=@weightRecycle,
		WeightCookie=@weightCookie		
	WHERE
		Id = @Id
END


GO
/****** Object:  StoredProcedure [dbo].[SSBC_Formula_Update]    Script Date: 3/14/2020 11:41:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SSBC_Formula_Update]
@ColorCode int,
@ColorName nvarchar(150)='',
@PP nvarchar(50)=''
as

if not exists(select ColorCode from SSBC_Formula where ColorCode=@ColorCode)
begin
	insert into SSBC_Formula values(@ColorCode,@ColorName,@PP,'Hieu',getdate(),'Hieu',GETDATE())
end


Select 'Xong ' Msg



GO
