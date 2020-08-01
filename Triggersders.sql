----Triggers(Tetikleyici)
---Bir tablo da ger�ekle�en sorgu sonucuna g�re
---ba�ka bir sorgunun �al��mas�n� sa�layan sql komutlar�

-----------------------
--Procedure den fark� kullan�c� taraf�ndan tetiklenmemesidir.
---(exec proc_ismi diyerek �al��t�r�yoruduk,bunda gerek yok)
--Trigger 2 �ekilde �al���r 
---1-)ilki anasorguyu engellemek(instead of)sorgu ger�ekle�meden kontrol
---2-)sorgu ger�ekle�tikten sonra(after-for)



---after (ilgili i�lem bittikten sonra ger�ekle�en)
---for(ilgili i�lem devam ederken ger�ekle�ir)
--
--------------------------------------------syntax

--Create trigger uyari_eklendi ---triggerismi
--ON tb_Kitaplar---Hangi tabloda i�lem yap�lacak ?
--WITH ENCRYPTION--YAZARSAK KODLARIMIZ GOZUKMEYECEK
--AFTER INSERT ---Ekleme i�lemi yap�ld�ktan sonra
--as
--BEGIN--S�sl� parantez
--SELECT  'Yeni kitap eklendi' as Uyar�
--END

--ilgili tetikleyici �al��t� demek

INSERT INTO [dbo].[tb_Kitaplar]([kitapadi],[kitapsayfasi],[yazarID],[KitaptipID],[Okunma],[OkunmaSayisi])
VALUES ('Siyah G�vercin',30,6,5,'Okundu',1)
--INSERT INTO [dbo].[tb_Kitaplar]([kitapadi],[kitapsayfasi],[yazarID],[KitaptipID])
--VALUES ('Kiral�k Konak3',300,3,1)
--INSERT INTO [dbo].[tb_Kitaplar]([kitapadi],[kitapsayfasi],[yazarID],[KitaptipID])
--VALUES ('Kiral�k Konak4',300,3,1)



----------------------------------------------------------------
--�smini de�i�tirmek i�in
----------------------------------------------------------------
--sp_rename 'uyar�_guncellendi' ,'uyari_guncellendi'
--sp_rename 'uyar�_silme' ,'uyari_silme'


--Caution: Changing any part of an object name could break scripts and stored procedures.
--Bozuklu�a sebeb olabilir.
----------------------------------------------------------------



----------------------------------------------------------------
------S�LME
----------------------------------------------------------------
ALTER trigger uyari_silme
ON tb_Kitaplar
AFTER DELETE
AS BEGIN TRY
 
SELECT 'Silme yap�ld� ve ba�ka tabloya eklendi.' as Uyar�
select * from deleted
END TRY
BEGIN CATCH

SELECT 'HATA' as Uyar�

END CATCH

select  * from uyari_eklendi
DELETE FROM tb_Kitaplar WHERE kitapadi='Alper3'
----------------------------------------------------------------



----------------------------------------------------------------
--TRIGGER'da g�ncelleme uyar�s�
----------------------------------------------------------------
ALTER trigger uyari_guncellendi
ON tb_Kitaplar
AFTER UPDATE
AS BEGIN TRY
 
SELECT 'G�ncelleme yap�ld�' as Uyar�
--select * from inserted
--select * from deleted
END TRY
BEGIN CATCH

SELECT 'HATA' as Uyar�
END CATCH
disable trigger uyari_guncellendi on tb_Kitaplar
enable trigger uyari_guncellendi on tb_Kitaplar
----------------------------------------------------------------
----(sadece boyle cag�ram�yoruz)  select * from inserted
----------------------------------------------------------------
----------------------------------------------------------------
update tb_Kitaplar set kitapadi='Yeni Kiral�k Konak2' where kitapadi='Yeni Kiral�k Konak5'
----------------------------------------------------------------

----------------------------------------------------------------
----HER GUNCELEME YAPILDIGINDA ba�ka bir tabloda SAYAC ARTSIN
----------------------------------------------------------------
--ALTER trigger sayac_art�r
--ON tb_Kitaplar 
--AFTER UPDATE
--NOT FOR REPLICATION 
--AS BEGIN 
--UPDATE tb_Sayac SET Sayac=Sayac+1 ---tb_Sayac tablosuna
--END
----------------------------------------------------------------



----------------------------------------------------------------
--Kullan�c� kitap tablosuna ekleme yapt���nda ba�ka tabloyada ayn� verileri ekleme
----------------------------------------------------------------
--ALTER TRIGGER kitabitabloyaekle
--ON tb_Kitaplar
--FOR INSERT  --EKLEME YAPMADAN �NCE BA�KA TABLOYA EKLEMEK ���N
--NOT FOR REPLICATION 
--AS BEGIN
--INSERT INTO tb_yenikitap(ISSBN,kitapadi,kitapsayfasi)
--SELECT ISSBN,kitapadi,kitapsayfasi from inserted
--SELECT * FROM tb_yenikitap

--END

--INSERT INTO [dbo].[tb_Kitaplar]([kitapadi],[kitapsayfasi],[yazarID],[KitaptipID],[Okunma],[OkunmaSayisi])
--VALUES ('Ak�ll� Ev',223,4,2,'Okundu',2)

--disable trigger kitabitabloyaekle on tb_Kitaplar
--enable trigger kitabitabloyaekle on tb_Kitaplar

----------------------------------------------------------------
--Kullan�c� bir kitap ekledikten sonra kitaplar tablosunu listeleyen trigger olu�tural�m.
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
--Kitaplar tablosundan kitap silindi�inde  ba�ka bir tabloya o kitab� ekleme
----------------------------------------------------------------
--ALTER TRIGGER kitabiekle
--ON tb_Kitaplar
--FOR DELETE --kitab� silmeden �NCE 
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
--Kitaplar tablosunda olan bir kitab� g�ncelleme yapt���mda updkitap adl� tabloma g�ncellenmi� ve eski verileri 
--insert etmek 
----------------------------------------------------------------

ALTER TRIGGER kitabiguncelle
ON tb_Kitaplar
AFTER UPDATE 
NOT FOR REPLICATION 
AS BEGIN


INSERT INTO tb_updkitap(new_ISSBN,new_kitapadi,new_kitapsayfasi,new_yazarID,new_KitaptipID,olay)
SELECT ISSBN,kitapadi,kitapsayfasi,yazarID,KitaptipID,'G�ncelleme sonras�' from inserted   -- G�ncellendikten sonra tabloya eklenmi� veriler

INSERT INTO tb_updkitap(new_ISSBN,new_kitapadi,new_kitapsayfasi,new_yazarID,new_KitaptipID,olay)
SELECT ISSBN,kitapadi,kitapsayfasi,yazarID,KitaptipID,'G�ncelleme �ncesi' from deleted  --Silinmeden �nceki veriler

--SELECT 'G�ncelleme yap�ld� aslan' as Uyar�
select * from deleted
select * from inserted
select new_ISSBN,new_kitapadi,new_kitapsayfasi,new_yazarID,new_KitaptipID,olay,guncelleyenID from tb_updkitap,tb_Kitaplar where tb_Kitaplar.ISSBN=new_ISSBN
END

--UPDATE tb_Kitaplar SET kitapadi='Alper Maceralari1',KitaptipID=4 WHERE ISSBN=40009
----------------------------------------------------------------



--DATEDIFF(YEAR,2018-03-17 ,Getdate())
----------------------------------------------------------------
--tb_Ogrenci tablosuna ya�� 18 den b�y�k  verileri eklemek trigger ile
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
--    RAISERROR ('Kitap say�s� tutmuyor',16,1) --HERHANG� B�R ��LEM YAPMADAN GER� D�ND�R�YORUZ

--END 
--ELSE BEGIN
--INSERT INTO tb_Ogrenci
-- Select id,Sad,Ssoyad,Dtdogumgunu,Cinsiyet,Sinif,OkuduguKitapSayisi  from inserted

 

--END 
--END



--disable trigger yasbuyuk on tb_Ogrenci
--enable trigger yasbuyuk on tb_Ogrenci
----------------------------------------------------------------
--Ogrenci tablosuna sadece 10 kitaptan fazla kitap okuyanlar� eklemek i�in trigger
----------------------------------------------------------------
--ALTER TRIGGER trigogrkitapcontrol
--ON tb_Ogrenci
--AFTER INSERT
--NOT FOR REPLICATION 
--AS BEGIN
--if (exists(Select * from inserted where inserted.OkuduguKitapSayisi<10))
--BEGIN 
--raiserror ('Kitap okuma oran�n cok dusuk aslan�m',1,1)
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
--Kitap Tablosunda kitap sildi�imde sayac�  okunma say�s� kadar azaltmas� i�in trigger
----------------------------------------------------------------

ALTER TRIGGER sayac_azalt
ON tb_Kitaplar
AFTER DELETE
NOT FOR REPLICATION 
AS BEGIN
DECLARE @OkunmaSayisi int


SELECT @OkunmaSayisi=OkunmaSayisi FROM deleted
UPDATE tb_Sayac SET Sayac=Sayac-@OkunmaSayisi
PRINT 'Okunma Say�s� kadar sayactan silindi.'
--Rollback tran--h�cbir �ey yapmadan geri d�nd�r�r(yap�lan i�lemi geri al�r)
END


DELETE FROM tb_Kitaplar Where ISSBN=40022



INSERT INTO [dbo].[tb_Kitaplar]([kitapadi],[kitapsayfasi],[yazarID],[KitaptipID],[Okunma],[OkunmaSayisi])
VALUES ('Halilin Merak� K�t� Bitti',223,4,2,'Okundu',2)
disable trigger sayac_azalt on tb_Kitaplar
enable trigger sayac_azalt on tb_Kitaplar




-------------�NSTEAD OF

--instead of(yerine demek) insert update veya deleten�n yer�ne kullan�l�r
--- kontrol ama�l� kullan�lan 
-- bir sorgu yazd�k bir kay�t i�lemi gercekle�tirmeden bu kay�t� ger�ekle�iyor mu?
--Yerine Tetikleyiciler( INSTEAD OF TRIGGER)
--Bir INSERT, UPDATE veya DELETE i�lemi bir tabloya uyguland���nda bu tablo �zerinde , 
--s�ras�yla bir Instead Of INSERT, Instead Of UPDATE veya Instead Of DELETE tetikleyici 
--varsa bu i�lem tablo �zerinde ger�ekle�mez. Onun yerine tetikleyici i�inde yaz�l� kodlar
--yap�l�r.



----------------------------------------------------------------
--Ogrenci tablosundan hi�bir kay�t silinmemesi i�in trigger
----------------------------------------------------------------
ALTER TRIGGER uyari_silme_ogr
ON tb_Ogrenci

AFTER DELETE
NOT FOR REPLICATION 
AS BEGIN
raiserror('Ogrenci Tablosu �zerinde kay�t silinmez',1,1)
rollback transaction--yap�lan i�lemi geri ald�m
end
DELETE FROM tb_Ogrenci Where id=2020
select * from sys.triggers
DISABLE trigger uyari_silme_ogr on tb_Ogrenci
enable trigger uyari_silme_ogr on tb_Ogrenci
--hata durumu 1 mesaj i�erikli 1-25 aras� olabilir 11 alt� mesaj vermek i�in 16 kullan�c� hatas� 
--oldugunu g�sterir , di�er 1 ise hatan�n durumunu
--seviyeler ile ilgili k�sa bilgi 
--1-10 - bilgilendirme ama�l�d�r/ba�lant� kesilmez/print ile ayn� i�lev
--11-16 - kullan�c� kaynakl� hatad�r/ hatan�n d�zeltilip submit etmesini beklemek gerekir/ exception olarak ele al�nabilir
--17-19 - �l�mc�l olmayan yaz�l�m veya Donan�m hatas�/ ba�lant� kesilmez
--17 - yetersiz Kaynak/ ReadOnly disk, okumaya kilitli tablo, yetersiz eri�im 
--18 - dahili Yaz�l�m�n kendisinden kaynakl� hata. 
--19 - SQL Server k�s�t�na tak�ld�
--33 - seviye SP �a��rmak, 1025.parametre�
--20-25 - �l�mc�l yaz�l�m veya donan�m hatas�/Administrator ekleyebilir
--Ba�lant� korunmaz kesilir. kullan�c�n�n yeniden ba�lant� sa�lamas� �art� vard�r.
************************************************************************************************
************************************************************************************************
--After yerine Instead of kullan�larak delete i�lemi yapmak yerine hata vermesi sa�lanabilir.
ALTER TRIGGER uyari_silme_ogr_instead
ON tb_Ogrenci
INSTEAD OF DELETE
NOT FOR REPLICATION 
AS BEGIN
raiserror('- Tablo- �zerinde kay�t silinmez',1,1)
rollback transaction
end
DISABLE trigger uyari_silme_ogr_instead on tb_Ogrenci