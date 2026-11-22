from r1 import add
add('mx_chilaquiles','Meksika','Kahvaltılık','Kolay',10,20,2,'Chilaquiles','Chilaquiles Rojos','Chilaquiles Rojos',
[('tortilla','Mısır Tortillası','Corn Tortillas','8','pc'),('domates','Domates','Tomatoes','4','pc'),('biber','Jalapeño','Jalapeño','1','pc'),('sogan','Soğan','Onion','0.5','pc'),('peynir','Queso Fresco / Beyaz Peynir','Crumbled Fresh Cheese','100','g'),('yumurta','Yumurta','Eggs','2','pc'),('krema','Ekşi Krema','Sour Cream','2','tbsp')],
[('pan',480,'Cips','Tortillaları üçgen kesip kızgın yağda altın ve çıtır olana kadar kızartın, süzün, tuzlayın.','Fry the Chips','Cut tortillas into triangles, fry in hot oil until golden and crisp, drain and salt.','',''),
('pot',600,'Kırmızı Sos','Domates, jalapeño, soğan ve sarımsağı haşlayıp blenderda çekin, tavada yağda 5 dakika kaynatın.','Red Salsa','Simmer tomatoes, jalapeño, onion and garlic until soft, blend and cook in oil for 5 minutes.','',''),
('pan',120,'Birleştirme','Cipsi sosa atıp 1 dakika karıştırın (hâlâ çıtır kalmalı).','Toss','Toss chips in the salsa for 1 minute; they should keep some crunch.','Fazla beklerseniz yumuşar; hemen servis edin.','Serve immediately or they go soggy.'),
('plate',120,'Servis','Üstüne peynir, krema, soğan ve sahanda yumurta koyun.','Serve','Top with cheese, cream, onion and a fried egg.','','')])

add('us_mac','ABD','Ana Yemek','Kolay',10,30,4,'Macaroni_and_cheese','Mac and Cheese','Mac and Cheese',
[('makarna','Dirsek Makarna','Elbow Macaroni','300','g'),('peynir','Çedar (rendelenmiş)','Grated Cheddar','250','g'),('tereyagi','Tereyağı','Butter','3','tbsp'),('un','Un','Flour','3','tbsp'),('sut','Süt','Milk','2.5','cup'),('galeta','Galeta Unu','Breadcrumbs','0.5','cup')],
[('pot',600,'Makarna','Makarnayı paket süresinden 2 dakika az haşlayın.','Pasta','Boil macaroni 2 minutes short of the package time.','',''),
('pot',420,'Beşamel','Tereyağında unu 1 dakika kavurun, sütü azar azar ekleyip koyulaşana kadar karıştırın, peyniri eritin.','Cheese Sauce','Cook flour in butter 1 minute, whisk in milk gradually until thick, then melt in the cheese.','Peyniri ateşten alarak ekleyin, pürüzsüz kalır.','Add the cheese off the heat for a smooth sauce.'),
('oven',1200,'Fırın','Makarna ve sosu birleştirip kaba alın, üstüne galeta serpip 200°C’de 15-20 dakika kızartın.','Bake','Combine pasta and sauce, top with breadcrumbs and bake at 200°C for 15-20 minutes.','','')])

add('br_paodequeijo','Brezilya','Hamur İşi','Kolay',10,25,6,'Pão_de_queijo','Pão de Queijo','Pão de Queijo',
[('nisasta','Tapyoka Nişastası','Tapioca Starch','2','cup'),('peynir','Peynir (parmesan benzeri)','Hard Cheese, grated','1','cup'),('sut','Süt','Milk','0.75','cup'),('yag','Sıvı Yağ','Oil','0.5','cup'),('yumurta','Yumurta','Eggs','2','pc')],
[('pot',180,'Sıcak Karışım','Süt, yağ ve tuzu kaynatıp tapyokanın üzerine dökün, karıştırın.','Scald','Boil milk, oil and salt and pour over the tapioca starch.','',''),
('bowl',300,'Hamur','Yumurta ve peyniri ekleyip pürüzsüz yapışkan bir hamur oluşana kadar yoğurun.','Dough','Work in eggs and cheese until a smooth sticky dough forms.','',''),
('oven',1500,'Pişirme','Ceviz boyunda toplar yapıp 200°C fırında 20-25 dakika şişip hafif sararana kadar pişirin.','Bake','Roll into walnut-sized balls and bake at 200°C for 20-25 minutes until puffed and pale gold.','Glütensizdir.','Naturally gluten-free.')])

add('ar_chimichurri','Arjantin','Ana Yemek','Kolay',15,15,2,'Chimichurri','Chimichurri Soslu Biftek','Steak with Chimichurri',
[('et','Antrikot veya Bonfile','Ribeye or Sirloin','2','pc'),('maydanoz','Maydanoz','Parsley','1','bunch'),('sarimsak','Sarımsak','Garlic','3','clove'),('sirke','Kırmızı Şarap Sirkesi','Red Wine Vinegar','2','tbsp'),('zeytinyagi','Zeytinyağı','Olive Oil','0.5','cup'),('biber','Pul Biber','Chili Flakes','1','tsp')],
[('bowl',300,'Chimichurri','Maydanoz ve sarımsağı ince doğrayın, sirke, yağ, pul biber ve tuzla karıştırın; en az 15 dakika bekletin.','Chimichurri','Finely chop parsley and garlic and mix with vinegar, oil, chili and salt; rest at least 15 minutes.','',''),
('pan',480,'Biftek','Eti oda sıcaklığına getirip tuzlayın, çok sıcak tavada her yüzü 3-4 dakika mühürleyin.','Sear','Bring steaks to room temperature, salt and sear in a very hot pan for 3-4 minutes a side.','',''),
('plate',300,'Dinlendirme','Eti 5 dakika dinlendirip dilimleyin ve sosla servis edin.','Rest','Rest 5 minutes, slice and serve with the sauce.','Dinlenmeyen et suyunu kaybeder.','Unrested meat loses its juices.')])

add('pe_ceviche','Peru','Ana Yemek','Kolay',20,0,2,'Ceviche','Ceviche','Peruvian Ceviche',
[('balik','Taze Beyaz Balık Filetosu','Very Fresh White Fish Fillet','400','g'),('limon','Misket Limonu Suyu','Lime Juice','0.5','cup'),('sogan','Kırmızı Soğan','Red Onion','1','pc'),('biber','Acı Biber','Hot Chili','1','pc'),('kisnis','Kişniş','Cilantro','1','bunch'),('misir','Haşlanmış Mısır','Boiled Corn','1','pc')],
[('knife',300,'Balığı Kesme','Balığı 2 cm küp doğrayın, tuzla karıştırın.','Cut the Fish','Cut the fish into 2 cm cubes and salt it.','Sadece çok taze, sashimi kalitesi balık kullanın.','Use only very fresh, sashimi-grade fish.'),
('bowl',600,'Marine','Limon suyu, soğan ve biberle karıştırıp 10 dakika bekletin; balık dışı beyazlaşır.','Cure','Toss with lime juice, onion and chili and wait 10 minutes until opaque outside.','',''),
('plate',60,'Servis','Kişnişle ve mısırla hemen servis edin.','Serve','Serve immediately with cilantro and corn.','','')])

add('co_ajiaco','Kolombiya','Çorba','Orta',20,70,6,'Ajiaco','Ajiaco','Ajiaco Bogotano',
[('tavuk','Tavuk Göğsü','Chicken Breast','600','g'),('patates','Patates (3 çeşit)','Potatoes (3 kinds)','900','g'),('misir','Mısır Koçanı','Corn on the Cob','3','pc'),('krema','Krema','Cream','0.5','cup'),('kapari','Kapari','Capers','2','tbsp'),('avokado','Avokado','Avocado','1','pc')],
[('pot',1800,'Et Suyu','Tavuğu soğan, sarımsakla 30 dakika haşlayın; tavuğu çıkarıp didikleyin.','Poach','Poach chicken with onion and garlic for 30 minutes; remove and shred.','',''),
('pot',2400,'Patatesler','Patatesleri sırayla ekleyin; biri dağılarak çorbayı kıvamlandırır. Mısır ekleyip 30 dakika pişirin.','Potatoes','Add potatoes in order; one variety breaks down to thicken the soup. Add corn and cook 30 minutes.','',''),
('plate',120,'Servis','Tavuğu geri ekleyin; krema, kapari ve avokadoyla servis edin.','Serve','Return the chicken; serve with cream, capers and avocado.','','')])

add('ca_poutine','Kanada','Pratik','Kolay',10,30,2,'Poutine','Poutine','Poutine',
[('patates','Patates','Potatoes','600','g'),('peynir','Taze Çedar Peyniri (topak)','Cheese Curds','200','g'),('et','Kahverengi Et Sosu (gravy)','Brown Gravy','1.5','cup')],
[('oven',1800,'Patates','Patatesleri kalın çubuk kesip 220°C fırında veya kızgın yağda çıtır olana kadar pişirin.','Fries','Cut thick fries and bake at 220°C or deep-fry until crisp.','',''),
('pot',300,'Sos','Gravy’yi sıcak tutun.','Gravy','Keep the gravy piping hot.','',''),
('plate',60,'Birleştirme','Sıcak patatesin üzerine peynir topaklarını koyup sosu dökün; peynir hafif erimeli ve gıcırdamalı.','Assemble','Top hot fries with curds and pour over gravy; the curds should soften but stay squeaky.','','')])

add('jm_jerk','Jamaika','Ana Yemek','Orta',20,50,4,'Jamaican_jerk','Jamaika Jerk Tavuğu','Jamaican Jerk Chicken',
[('tavuk','Tavuk But','Chicken Thighs','1','kg'),('biber','Scotch Bonnet Biber','Scotch Bonnet Pepper','1','pc'),('sogan','Taze Soğan','Scallions','4','pc'),('misket','Yenibahar','Allspice','1','tbsp'),('sarimsak','Sarımsak','Garlic','4','clove'),('soya','Soya Sosu','Soy Sauce','3','tbsp'),('limon','Misket Limonu','Lime','1','pc')],
[('bowl',300,'Marine','Biber, taze soğan, yenibahar, sarımsak, soya ve limonu blenderda çekin; tavuğa bulayıp 1 saat (tercihen gece) bekletin.','Marinade','Blend the pepper, scallions, allspice, garlic, soy and lime, coat the chicken and marinate 1 hour or overnight.','Scotch Bonnet çok acıdır, eldiven kullanın.','Scotch bonnet is very hot; wear gloves.'),
('grill',2400,'Pişirme','Orta ateşte ızgarada veya 200°C fırında 35-40 dakika, ara ara çevirerek pişirin.','Cook','Grill over medium heat or bake at 200°C 35-40 minutes, turning.','',''),
('plate',60,'Servis','İç ısı 74°C’ye ulaşınca servis edin.','Serve','Serve when the inside reaches 74°C (165°F).','','')])

add('cu_frijoles','Küba','Ana Yemek','Kolay',15,50,4,'Moros_y_Cristianos','Moros y Cristianos (Küba Pilavı)','Moros y Cristianos',
[('fasulye','Kuru Siyah Fasulye (haşlanmış)','Cooked Black Beans','2','cup'),('pirinc','Pirinç','Rice','1.5','cup'),('sogan','Soğan','Onion','1','pc'),('biber','Yeşil Biber','Green Pepper','1','pc'),('sarimsak','Sarımsak','Garlic','3','clove'),('kimyon','Kimyon','Cumin','1','tsp')],
[('pot',420,'Sofrito','Soğan, biber, sarımsağı zeytinyağında yumuşatın, kimyonu ekleyin.','Sofrito','Soften onion, pepper and garlic in oil and add cumin.','',''),
('pot',1500,'Pişirme','Fasulyeyi suyuyla, pirinç ve tuzla ekleyin; sıvı pirinç seviyesinde olunca kapağı kapatıp kısık ateşte 20 dakika pişirin.','Cook','Add beans with their liquid, rice and salt; cover and cook on low for 20 minutes.','Pilavı pişerken karıştırmayın.','Do not stir while it cooks.'),
('plate',300,'Dinlendirme ve Servis','Ocağı kapatıp kapağı açmadan 5 dakika dinlendirin, çatalla havalandırıp sıcak servis edin.','Rest and Serve','Turn off the heat, rest 5 minutes with the lid on, fluff with a fork and serve hot.','','')])

add('ma_tagine','Fas','Ana Yemek','Orta',20,70,4,'Tajine','Fas Tavuk Tajini','Moroccan Chicken Tagine',
[('tavuk','Tavuk But','Chicken Thighs','1','kg'),('sogan','Soğan','Onions','2','pc'),('zeytin','Yeşil Zeytin','Green Olives','1','cup'),('limon','Turşu Limon','Preserved Lemon','1','pc'),('zencefil','Zencefil, Zerdeçal, Safran','Ginger, Turmeric, Saffron','1','tsp'),('sarimsak','Sarımsak','Garlic','3','clove')],
[('bowl',300,'Baharat','Tavuğu baharat, sarımsak ve zeytinyağıyla ovun.','Rub','Rub chicken with spices, garlic and olive oil.','',''),
('pot',3000,'Pişirme','Tavuğu dilimli soğan üzerine dizip yarım bardak su ekleyin, kapaklı kısık ateşte 45 dakika pişirin.','Braise','Lay chicken on sliced onions, add half a cup of water, cover and braise on low for 45 minutes.','',''),
('pot',600,'Zeytin ve Limon','Zeytin ve turşu limonu ekleyip kapaksız 10 dakika sosu koyulaştırın.','Olives and Lemon','Add olives and preserved lemon and reduce uncovered for 10 minutes.','','')])

add('eg_koshari','Mısır','Ana Yemek','Orta',20,45,6,'Koshary','Koshari (كشري)','Koshari (كشري)',
[('mercimek','Yeşil Mercimek','Brown Lentils','1','cup'),('pirinc','Pirinç','Rice','1','cup'),('makarna','Kısa Makarna','Short Pasta','1','cup'),('nohut','Nohut (haşlanmış)','Cooked Chickpeas','1','cup'),('sogan','Soğan','Onions','3','pc'),('domates','Domates Sosu','Tomato Sauce','2','cup')],
[('pan',1200,'Çıtır Soğan','Soğanları ince doğrayıp bol yağda koyu kahverengi olana kadar kızartın.','Crispy Onions','Slice onions thinly and fry in oil until deep brown.','',''),
('pot',1500,'Katmanlar','Mercimek, pirinç ve makarnayı ayrı ayrı pişirin; pirinç ve mercimeği karıştırın.','Layers','Cook lentils, rice and pasta separately and combine the rice and lentils.','',''),
('plate',120,'Servis','Kaseye makarna, pirinç-mercimek, nohut koyun; sıcak domates sosu ve çıtır soğanla tamamlayın.','Assemble','Bowl pasta, rice-lentils and chickpeas, then top with hot tomato sauce and crispy onions.','','')])

add('et_misir','Etiyopya','Vegan','Kolay',10,40,4,'Misir_wat','Misir Wot (ምስር ወጥ)','Misir Wot (ምስር ወጥ)',
[('mercimek','Kırmızı Mercimek','Red Lentils','1.5','cup'),('sogan','Soğan','Onions','2','pc'),('sarimsak','Sarımsak ve Zencefil','Garlic and Ginger','1','tbsp'),('berbere','Berbere Baharat','Berbere Spice','2','tbsp'),('domates','Domates Salçası','Tomato Paste','1','tbsp')],
[('pot',900,'Soğan','Soğanı yağsız kuru tencerede 10 dakika yumuşatıp yağ ekleyin.','Onions','Cook onions dry for 10 minutes, then add oil.','',''),
('pot',120,'Baharat','Sarımsak, zencefil, berbere ve salçayı 2 dakika kavurun.','Spice','Fry garlic, ginger, berbere and tomato paste for 2 minutes.','',''),
('pot',1500,'Mercimek','Mercimek ve 4 bardak su ekleyip 25 dakika koyulaşana kadar pişirin.','Lentils','Add lentils and 4 cups of water and simmer 25 minutes until thick.','Injera veya ekmekle servis edin.','Serve with injera or bread.')])

add('ng_jollof','Nijerya','Ana Yemek','Orta',20,50,6,'Jollof_rice','Jollof Pilavı','Jollof Rice',
[('pirinc','Uzun Taneli Pirinç','Long-grain Rice','3','cup'),('domates','Domates','Tomatoes','4','pc'),('biber','Kırmızı Biber','Red Peppers','2','pc'),('sogan','Soğan','Onions','2','pc'),('tavuk','Tavuk Suyu','Chicken Stock','3','cup'),('baharat','Kerri, Kekik, Defne','Curry, Thyme, Bay','2','tsp')],
[('blender',300,'Sos','Domates, biber ve yarım soğanı blenderdan geçirin.','Blend','Blend tomatoes, peppers and half the onion.','',''),
('pot',1200,'Sos Pişirme','Kalan soğanı yağda kavurun, püreyi ekleyip suyunu çekene ve yağı çıkarana kadar 20 dakika pişirin.','Cook the Base','Fry remaining onion, add the purée and reduce 20 minutes until the oil separates.','',''),
('pot',1500,'Pirinç','Yıkanmış pirinç ve suyu ekleyin, folyo ve kapakla çok kısık ateşte 25 dakika buharda pişirin.','Rice','Add washed rice and stock, seal with foil and lid and steam on very low for 25 minutes.','Alttaki hafif yanık “party jollof” aromasıdır.','A light scorch at the bottom adds the signature smoky flavour.')])

add('za_bobotie','Güney Afrika','Ana Yemek','Kolay',20,45,6,'Bobotie','Bobotie','Bobotie',
[('kiyma','Dana Kıyma','Ground Beef','600','g'),('sogan','Soğan','Onion','1','pc'),('baharat','Kerri Tozu','Curry Powder','2','tbsp'),('kuru','Kuru Kayısı','Dried Apricots','0.25','cup'),('yumurta','Yumurta','Eggs','2','pc'),('sut','Süt','Milk','1','cup')],
[('pan',600,'Et','Soğanı yağda kavurun, kıymayı ekleyip kerri ve kayısıyla pişirin.','Meat','Fry onion, add meat, curry powder and apricots.','',''),
('bowl',120,'Üst Harç','Yumurta ve sütü çırpın.','Custard','Whisk eggs and milk.','',''),
('oven',2400,'Fırın','Eti kaba bastırıp yumurta karışımını dökün, 180°C’de 30 dakika pişirin.','Bake','Press meat into a dish, pour custard over and bake at 180°C for 30 minutes.','','')])

add('tn_shakshuka','Tunus','Kahvaltılık','Kolay',10,25,2,'Shakshouka','Şakşuka (Tunus Usulü)','Shakshuka',
[('domates','Domates','Tomatoes','5','pc'),('biber','Kırmızı Biber','Red Pepper','1','pc'),('sogan','Soğan','Onion','1','pc'),('yumurta','Yumurta','Eggs','4','pc'),('baharat','Kimyon ve Harissa','Cumin and Harissa','1','tsp')],
[('pan',600,'Sos','Soğan ve biberi yağda yumuşatın, baharat ve rendelenmiş domatesi ekleyip 12 dakika koyulaştırın.','Sauce','Soften onion and pepper, add spices and grated tomatoes and reduce 12 minutes.','',''),
('pan',420,'Yumurta','Sosta çukurlar açıp yumurtaları kırın, kapağı kapatıp 6-7 dakika pişirin.','Eggs','Make wells in the sauce, crack in the eggs, cover and cook 6-7 minutes.','Beyazlar tutunca, sarılar hâlâ sulu olmalı.','Whites set while yolks stay runny.'),
('plate',120,'Servis','Tavayı doğrudan sofraya getirip taze maydanoz ve sıcak ekmekle servis edin.','Serve','Bring the pan straight to the table and serve with fresh parsley and warm bread.','','')])

add('lb_tabbouleh','Lübnan','Salata','Kolay',20,0,4,'Tabbouleh','Tabule (تبولة)','Tabbouleh (تبولة)',
[('maydanoz','Maydanoz','Flat Parsley','3','bunch'),('bulgur','İnce Bulgur','Fine Bulgur','0.25','cup'),('domates','Domates','Tomatoes','3','pc'),('nane','Nane','Mint','0.5','bunch'),('limon','Limon','Lemon','2','pc'),('zeytinyagi','Zeytinyağı','Olive Oil','0.25','cup')],
[('knife',600,'Doğrama','Maydanozu çok ince doğrayın, kurulayın. Domatesi küçük küp kesin.','Chop','Chop parsley very finely and dry it; dice the tomatoes small.','Maydanoz bulgurdan çok olmalı; bu bir ot salatasıdır.','Parsley, not bulgur, should dominate.'),
('bowl',300,'Bulgur','Bulguru domates suyu ve limonla 10 dakika ıslatın.','Soften Bulgur','Soak bulgur in tomato juice and lemon for 10 minutes.','',''),
('bowl',60,'Karıştırma','Hepsini zeytinyağı ve tuzla karıştırın.','Toss','Toss everything with olive oil and salt.','','')])

add('ir_kukusabzi','İran','Kahvaltılık','Orta',20,30,4,'Kuku_sabzi','Kuku Sabzi (کوکو سبزی)','Kuku Sabzi (کوکو سبزی)',
[('maydanoz','Maydanoz, Dereotu, Kişniş (karışık)','Mixed Parsley, Dill, Cilantro','3','cup'),('yumurta','Yumurta','Eggs','6','pc'),('ceviz','Ceviz','Walnuts','0.5','cup'),('berberis','Kızılcık','Barberries','2','tbsp'),('zerdecal','Zerdeçal','Turmeric','0.5','tsp')],
[('knife',420,'Otlar','Otları çok ince doğrayın.','Herbs','Chop the herbs very finely.','',''),
('bowl',180,'Karışım','Yumurta, zerdeçal, tuz ve cevizi ekleyip karıştırın.','Mix','Mix with eggs, turmeric, salt and walnuts.','',''),
('pan',1200,'Pişirme','Yağlı tavada kapağı kapalı 10 dakika, çevirip 8 dakika daha pişirin.','Cook','Cook in an oiled pan, covered, 10 minutes, flip and cook 8 minutes more.','','')])

add('ge_khachapuri','Gürcistan','Hamur İşi','Orta',90,20,2,'Khachapuri','Gürcü Peynirli Teknesi (Khachapuri Adjaruli)','Khachapuri Adjaruli (ხაჭაპური)',
[('un','Un','Flour','3','cup'),('maya','Maya','Yeast','1','tsp'),('peynir','Mozzarella ve Beyaz Peynir','Mozzarella and Feta','400','g'),('yumurta','Yumurta','Eggs','3','pc'),('tereyagi','Tereyağı','Butter','2','tbsp')],
[('bowl',3600,'Hamur','Un, maya, tuz ve ılık suyla hamuru yoğurup 1 saat mayalayın.','Dough','Knead flour, yeast, salt and warm water and proof 1 hour.','',''),
('plate',300,'Kayık','Hamuru oval açıp kenarları kıvırarak kayık şekli verin; peynirle doldurun.','Boat','Roll into an oval, roll the edges to form a boat and fill with cheese.','',''),
('oven',900,'Pişirme','230°C fırında 12-15 dakika pişirin; çıkınca ortasına yumurta sarısı ve tereyağı koyup karıştırarak yiyin.','Bake','Bake at 230°C 12-15 minutes then add an egg yolk and butter in the centre and stir while eating.','','')])

add('uz_plov','Özbekistan','Ana Yemek','Orta',20,90,6,'Pilaf','Özbek Pilavı (Plov)','Uzbek Plov',
[('pirinc','Pirinç','Rice','3','cup'),('et','Kuzu veya Dana Eti','Lamb or Beef','600','g'),('havuc','Sarı Havuç (çubuk)','Yellow Carrots','500','g'),('sogan','Soğan','Onions','2','pc'),('sarimsak','Bütün Sarımsak Başı','Whole Garlic Head','1','pc'),('kimyon','Kimyon','Cumin','1','tbsp')],
[('pot',900,'Zirvak','Etleri yağda renk alana kadar kızartın, soğanı ve havucu ekleyip 15 dakika pişirin.','Zirvak','Brown the meat in oil, add onions and carrots and cook 15 minutes.','',''),
('pot',1200,'Pirinç','Pirinci ekleyip üzerine su koyun (parmak seviyesi), bütün sarımsağı ortaya yerleştirin; su çekilene kadar bırakın.','Rice','Layer rice over the base, add water a finger above, nestle in the garlic head and cook until water is absorbed.','',''),
('pot',1200,'Buğulama','Delikler açıp kapağı kapatın ve kısık ateşte 20 dakika demlenmeye bırakın.','Steam','Poke holes, cover and steam on lowest heat 20 minutes.','','')])

add('au_pavlova','Avustralya','Tatlı','Orta',20,90,8,'Pavlova_(cake)','Pavlova','Pavlova',
[('yumurta','Yumurta Akı','Egg Whites','4','pc'),('seker','Pudra Şekeri','Caster Sugar','1','cup'),('nisasta','Mısır Nişastası','Cornstarch','1','tsp'),('krema','Krema','Whipping Cream','1','cup'),('meyve','Çilek, Kivi, Böğürtlen','Berries and Kiwi','300','g')],
[('whisk',600,'Beze','Yumurta aklarını sert zirve alana kadar çırpın, şekeri azar azar ekleyin; nişastayı katın.','Meringue','Whip whites to stiff peaks, adding sugar gradually, then fold in the cornstarch.','Karışım parlak ve pürüzsüz olunca hazırdır.','It is ready when glossy and the sugar has dissolved.'),
('oven',5400,'Pişirme','Yuvarlak yayıp 120°C fırında 1.5 saat pişirin, fırın kapalı kalarak soğutun.','Bake','Shape into a round, bake at 120°C for 1.5 hours and cool in the oven.','',''),
('plate',180,'Süsleme','Kremayı çırpıp üstüne yayın, meyvelerle süsleyin.','Top','Whip cream, spread on top and decorate with fruit.','','')])

add('kh_amok','Kamboçya','Ana Yemek','Orta',30,25,4,'Fish_amok','Balık Amok','Fish Amok',
[('balik','Beyaz Balık','White Fish','500','g'),('hindistancevizi','Hindistan Cevizi Sütü','Coconut Milk','400','ml'),('yumurta','Yumurta','Egg','1','pc'),('limonOtu','Limon Otu, Galangal, Zerdeçal','Lemongrass, Galangal, Turmeric','3','tbsp'),('lahana','Lahana Yaprağı','Cabbage Leaves','4','pc')],
[('mortar',600,'Kroeung','Baharat ezmesini havanda veya blenderda ezin.','Paste','Pound the spice paste.','',''),
('bowl',300,'Karışım','Hindistan cevizi sütü, yumurta ve ezmeyle balığı karıştırın.','Mix','Combine paste, coconut milk, egg and fish.','',''),
('pot',1500,'Buhar','Muz yaprağı veya lahana yapraklı kaselere doldurup 20 dakika buharda pişirin.','Steam','Fill leaf cups and steam for 20 minutes.','','')])

add('tw_scallion','Tayvan','Hamur İşi','Orta',45,10,3,'Scallion_pancake','Taze Soğanlı Krep (蔥油餅)','Scallion Pancake (蔥油餅)',
[('un','Un','Flour','2','cup'),('sogan','Taze Soğan','Scallions','5','pc'),('su','Sıcak Su','Hot Water','0.75','cup'),('susam','Susam Yağı','Sesame Oil','2','tbsp')],
[('bowl',900,'Hamur','Un ve sıcak suyla hamuru yoğurup 30 dakika dinlendirin.','Dough','Knead flour with hot water and rest 30 minutes.','',''),
('plate',300,'Katlama','İnce açıp yağ ve doğranmış soğan serpin, rulo yapıp sarmal şekle getirin ve yeniden açın.','Laminate','Roll thin, brush with oil, add scallions, roll up into a coil and flatten again.','Bu kıvrım çıtır katları yapar.','The coil creates flaky layers.'),
('pan',360,'Pişirme','Yağda her yüzü 3 dakika altın ve çıtır olana kadar pişirin.','Fry','Pan-fry 3 minutes per side until golden and crisp.','','')])
