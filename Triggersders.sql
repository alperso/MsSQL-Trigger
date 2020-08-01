----Triggers(Tetikleyici)
---Bir tablo da gerçekleþen sorgu sonucuna göre
---baþka bir sorgunun çalýþmasýný saðlayan sql komutlarý

-----------------------
--Procedure den farký kullanýcý tarafýndan tetiklenmemesidir.
---(exec proc_ismi diyerek çalýþtýrýyoruduk,bunda gerek yok)
--Trigger 2 þekilde çalýþýr 
---1-)ilki anasorguyu engellemek(instead of)sorgu gerçekleþmeden kontrol
---2-)sorgu gerçekleþtikten sonra(after-for)



---after (ilgili iþlem bittikten sonra gerçekleþen)
---for(ilgili iþlem devam ederken gerçekleþir)
--
--------------------------------------------syntax

--Create trigger uyari_eklendi ---triggerismi
--ON tb_Kitaplar---Hangi tabloda iþlem yapýlacak ?
--WITH ENCRYPTION--YAZARSAK KODLARIMIZ GOZUKMEYECEK
--AFTER INSERT ---Ekleme iþlemi yapýldýktan sonra
--as
--BEGIN--Süslü parantez
--SELECT  'Yeni kitap eklendi' as Uyarý
--END

--ilgili tetikleyici çalýþtý demek

INSERT INTO [dbo].[tb_Kitaplar]([kitapadi],[kitapsayfasi],[yazarID],[KitaptipID],[Okunma],[OkunmaSayisi])
VALUES ('Siyah Güvercin',30,6,5,'Okundu',1)
--INSERT INTO [dbo].[tb_Kitaplar]([kitapadi],[kitapsayfasi],[yazarID],[KitaptipID])
--VALUES ('Kiralýk Konak3',300,3,1)
--INSERT INTO [dbo].[tb_Kitaplar]([kitapadi],[kitapsayfasi],[yazarID],[KitaptipID])
--VALUES ('Kiralýk Konak4',300,3,1)



----------------------------------------------------------------
--Ýsmini deðiþtirmek için
----------------------------------------------------------------
--sp_rename 'uyarý_guncellendi' ,'uyari_guncellendi'
--sp_rename 'uyarý_silme' ,'uyari_silme'


--Caution: Changing any part of an object name could break scripts and stored procedures.
--Bozukluða sebeb olabilir.
----------------------------------------------------------------



----------------------------------------------------------------
------SÝLME
----------------------------------------------------------------
ALTER trigger uyari_silme
ON tb_Kitaplar
AFTER DELETE
AS BEGIN TRY
 
SELECT 'Silme yapýldý ve baþka tabloya eklendi.' as Uyarý
select * from deleted
END TRY
BEGIN CATCH

SELECT 'HATA' as Uyarý

END CATCH

select  * from uyari_eklendi
DELETE FROM tb_Kitaplar WHERE kitapadi='Alper3'
----------------------------------------------------------------



----------------------------------------------------------------
--TRIGGER'da güncelleme uyarýsý
----------------------------------------------------------------
ALTER trigger uyari_guncellendi
ON tb_Kitaplar
AFTER UPDATE
AS BEGIN TRY
 
SELECT 'Güncelleme yapýldý' as Uyarý
--select * from inserted
--select * from deleted
END TRY
BEGIN CATCH

SELECT 'HATA' as Uyarý
END CATCH
disable trigger uyari_guncellendi on tb_Kitaplar
enable trigger uyari_guncellendi on tb_Kitaplar
----------------------------------------------------------------
----(sadece boyle cagýramýyoruz)  select * from inserted
----------------------------------------------------------------
----------------------------------------------------------------
update tb_Kitaplar set kitapadi='Yeni Kiralýk Konak2' where kitapadi='Yeni Kiralýk Konak5'
----------------------------------------------------------------

----------------------------------------------------------------
----HER GUNCELEME YAPILDIGINDA baþka bir tabloda SAYAC ARTSIN
----------------------------------------------------------------
--ALTER trigger sayac_artÝr
--ON tb_Kitaplar 
--AFTER UPDATE
--NOT FOR REPLICATION 
--AS BEGIN 
--UPDATE tb_Sayac SET Sayac=Sayac+1 ---tb_Sayac tablosuna
--END
----------------------------------------------------------------



----------------------------------------------------------------
--Kullanýcý kitap tablosuna ekleme yaptýðýnda baþka tabloyada ayný verileri ekleme
----------------------------------------------------------------
--ALTER TRIGGER kitabitabloyaekle
--ON tb_Kitaplar
--FOR INSERT  --EKLEME YAPMADAN ÖNCE BAÞKA TABLOYA EKLEMEK ÝÇÝN
--NOT FOR REPLICATION 
--AS BEGIN
--INSERT INTO tb_yenikitap(ISSBN,kitapadi,kitapsayfasi)
--SELECT ISSBN,kitapadi,kitapsayfasi from inserted
--SELECT * FROM tb_yenikitap

--END

--INSERT INTO [dbo].[tb_Kitaplar]([kitapadi],[kitapsayfasi],[yazarID],[KitaptipID],[Okunma],[OkunmaSayisi])
--VALUES ('Akýllý Ev',223,4,2,'Okundu',2)

--disable trigger kitabitabloyaekle on tb_Kitaplar
--enable trigger kitabitabloyaekle on tb_Kitaplar

----------------------------------------------------------------
--Kullanýcý bir kitap ekledikten sonra kitaplar tablosunu listeleyen trigger oluþturalým.
----------------------------------------------------------------
ALTER TRIGGER goster_kitap
ON tb_Kitaplar
AFTER INSERT
NOT FOR REPLICATION 
AS BEGIN 
Select * from tb_Kitaplar
END

--INSERT INTO [dbo].[tb_Kitaplar]([kitapadi],[kitapsayfasi],[yazarID],[KitaptipID],[Okunma],[OkunmaSayisi])
--VALUES ('Mai ve Siyah',223,4,2,'Okundu',2)
--disable trigger goster_kitap on tb_Kitaplar
--enable trigger goster_kitap on tb_Kitaplar
----------------------------------------------------------------


----------------------------------------------------------------
--Kitaplar tablosundan kitap silindiðinde  baþka bir tabloya o kitabý ekleme
----------------------------------------------------------------
--ALTER TRIGGER kitabiekle
--ON tb_Kitaplar
--FOR DELETE --kitabý silmeden ÖNCE 
--NOT FOR REPLICATION 
--AS BEGIN
--INSERT INTO tb_delkitap(ISSBN,kitapadi,kitapsayfasi,yazarID,KitaptipID,Olay)
--SELECT ISSBN,kitapadi,kitapsayfasi,yazarID,KitaptipID,'Veri Silindi' from deleted  
--end

--DELETE FROM tb_Kitaplar WHERE ISSBN=40016


--disable trigger kitabiekle on tb_Kitaplar
--enable trigger kitabiekle on tb_Kitaplar
----------------------------------------------------------------


----------------------------------------------------------------
--Kitaplar tablosunda olan bir kitabý güncelleme yaptýðýmda updkitap adlý tabloma güncellenmiþ ve eski verileri 
--insert etmek 
----------------------------------------------------------------

ALTER TRIGGER kitabiguncelle
ON tb_Kitaplar
AFTER UPDATE 
NOT FOR REPLICATION 
AS BEGIN


INSERT INTO tb_updkitap(new_ISSBN,new_kitapadi,new_kitapsayfasi,new_yazarID,new_KitaptipID,olay)
SELECT ISSBN,kitapadi,kitapsayfasi,yazarID,KitaptipID,'Güncelleme sonrasý' from inserted   -- Güncellendikten sonra tabloya eklenmiþ veriler

INSERT INTO tb_updkitap(new_ISSBN,new_kitapadi,new_kitapsayfasi,new_yazarID,new_KitaptipID,olay)
SELECT ISSBN,kitapadi,kitapsayfasi,yazarID,KitaptipID,'Güncelleme öncesi' from deleted  --Silinmeden önceki veriler

--SELECT 'Güncelleme yapýldý aslan' as Uyarý
select * from deleted
select * from inserted
select new_ISSBN,new_kitapadi,new_kitapsayfasi,new_yazarID,new_KitaptipID,olay,guncelleyenID from tb_updkitap,tb_Kitaplar where tb_Kitaplar.ISSBN=new_ISSBN
END

--UPDATE tb_Kitaplar SET kitapadi='Alper Maceralari1',KitaptipID=4 WHERE ISSBN=40009
----------------------------------------------------------------



--DATEDIFF(YEAR,2018-03-17 ,Getdate())
----------------------------------------------------------------
--tb_Ogrenci tablosuna yaþý 18 den büyük  verileri eklemek trigger ile
----------------------------------------------------------------
--alter TRIGGER yasbuyuk 
--ON tb_Ogrenci
--AFTER INSERT
--AS BEGIN 
--DECLARE @sinir int
----SELECT @sinir=DATEDIFF(YEAR,Dtdogumgunu,Getdate()) from inserted
--SELECT @sinir=OkuduguKitapSayisi from inserted
--IF(@sinir>10)
--BEGIN

--ROLLBACK TRANSACTION
--    RAISERROR ('Kitap sayýsý tutmuyor',16,1) --HERHANGÝ BÝR ÝÞLEM YAPMADAN GERÝ DÖNDÜRÜYORUZ

--END 
--ELSE BEGIN
--INSERT INTO tb_Ogrenci
-- Select id,Sad,Ssoyad,Dtdogumgunu,Cinsiyet,Sinif,OkuduguKitapSayisi  from inserted

 

--END 
--END



--disable trigger yasbuyuk on tb_Ogrenci
--enable trigger yasbuyuk on tb_Ogrenci
----------------------------------------------------------------
--Ogrenci tablosuna sadece 10 kitaptan fazla kitap okuyanlarý eklemek için trigger
----------------------------------------------------------------
--ALTER TRIGGER trigogrkitapcontrol
--ON tb_Ogrenci
--AFTER INSERT
--NOT FOR REPLICATION 
--AS BEGIN
--if (exists(Select * from inserted where inserted.OkuduguKitapSayisi<10))
--BEGIN 
--raiserror ('Kitap okuma oranýn cok dusuk aslaným',1,1)
--rollback tran
--END

--END

--sp_rename 'kitapsayi','trigogrkitapcontrol'
----------------------------------------------------------------
INSERT INTO tb_Ogrenci(id,Sad,Ssoyad,Dtdogumgunu,Cinsiyet,Sinif,OkuduguKitapSayisi)
VALUES (40014,'Erdem','Cemile','1991-5-5',1,'10C',11)

SELECT * FROM sys.triggers
DISABLE trigger trigogrkitapcontrol on tb_Ogrenci
DELETE FROM tb_Ogrenci Where id=1240



--Select Dtdogumgunu FROM tb_Ogrenci WHERE id=200

--SELECT DATEDIFF(YEAR,Dtdogumgunu,Getdate()) AS Yas FROM tb_Ogrenci


----------------------------------------------------------------
--Kitap Tablosunda kitap sildiðimde sayacý  okunma sayýsý kadar azaltmasý için trigger
----------------------------------------------------------------

ALTER TRIGGER sayac_azalt
ON tb_Kitaplar
AFTER DELETE
NOT FOR REPLICATION 
AS BEGIN
DECLARE @OkunmaSayisi int


SELECT @OkunmaSayisi=OkunmaSayisi FROM deleted
UPDATE tb_Sayac SET Sayac=Sayac-@OkunmaSayisi
PRINT 'Okunma Sayýsý kadar sayactan silindi.'
--Rollback tran--hýcbir þey yapmadan geri döndürür(yapýlan iþlemi geri alýr)
END


DELETE FROM tb_Kitaplar Where ISSBN=40022



INSERT INTO [dbo].[tb_Kitaplar]([kitapadi],[kitapsayfasi],[yazarID],[KitaptipID],[Okunma],[OkunmaSayisi])
VALUES ('Halilin Meraký Kötü Bitti',223,4,2,'Okundu',2)
disable trigger sayac_azalt on tb_Kitaplar
enable trigger sayac_azalt on tb_Kitaplar




-------------ÝNSTEAD OF

--instead of(yerine demek) insert update veya deletenýn yerýne kullanýlýr
--- kontrol amaçlý kullanýlan 
-- bir sorgu yazdýk bir kayýt iþlemi gercekleþtirmeden bu kayýtý gerçekleþiyor mu?
--Yerine Tetikleyiciler( INSTEAD OF TRIGGER)
--Bir INSERT, UPDATE veya DELETE iþlemi bir tabloya uygulandýðýnda bu tablo üzerinde , 
--sýrasýyla bir Instead Of INSERT, Instead Of UPDATE veya Instead Of DELETE tetikleyici 
--varsa bu iþlem tablo üzerinde gerçekleþmez. Onun yerine tetikleyici içinde yazýlý kodlar
--yapýlýr.



----------------------------------------------------------------
--Ogrenci tablosundan hiçbir kayýt silinmemesi için trigger
----------------------------------------------------------------
ALTER TRIGGER uyari_silme_ogr
ON tb_Ogrenci

AFTER DELETE
NOT FOR REPLICATION 
AS BEGIN
raiserror('Ogrenci Tablosu üzerinde kayýt silinmez',1,1)
rollback transaction--yapýlan iþlemi geri aldým
end
DELETE FROM tb_Ogrenci Where id=2020
select * from sys.triggers
DISABLE trigger uyari_silme_ogr on tb_Ogrenci
enable trigger uyari_silme_ogr on tb_Ogrenci
--hata durumu 1 mesaj içerikli 1-25 arasý olabilir 11 altý mesaj vermek için 16 kullanýcý hatasý 
--oldugunu gösterir , diðer 1 ise hatanýn durumunu
--seviyeler ile ilgili kýsa bilgi 
--1-10 - bilgilendirme amaçlýdýr/baðlantý kesilmez/print ile ayný iþlev
--11-16 - kullanýcý kaynaklý hatadýr/ hatanýn düzeltilip submit etmesini beklemek gerekir/ exception olarak ele alýnabilir
--17-19 - ölümcül olmayan yazýlým veya Donaným hatasý/ baðlantý kesilmez
--17 - yetersiz Kaynak/ ReadOnly disk, okumaya kilitli tablo, yetersiz eriþim 
--18 - dahili Yazýlýmýn kendisinden kaynaklý hata. 
--19 - SQL Server kýsýtýna takýldý
--33 - seviye SP çaðýrmak, 1025.parametre…
--20-25 - ölümcül yazýlým veya donaným hatasý/Administrator ekleyebilir
--Baðlantý korunmaz kesilir. kullanýcýnýn yeniden baðlantý saðlamasý þartý vardýr.
************************************************************************************************
************************************************************************************************
--After yerine Instead of kullanýlarak delete iþlemi yapmak yerine hata vermesi saðlanabilir.
ALTER TRIGGER uyari_silme_ogr_instead
ON tb_Ogrenci
INSTEAD OF DELETE
NOT FOR REPLICATION 
AS BEGIN
raiserror('- Tablo- üzerinde kayýt silinmez',1,1)
rollback transaction
end
DISABLE trigger uyari_silme_ogr_instead on tb_Ogrenci