from r1 import add, R
# Turkish classics replacing generic template versions. 'cov' = generator base dish these supersede.
def t(id,cov,cat,d,p,k,sv,wiki,tr,en,ing,steps):
    add(id,'Türk Mutfağı',cat,d,p,k,sv,wiki,tr,en,ing,steps); R[-1]['cov']=cov

t('tr_karniyarik','Karnıyarık','Ana Yemek','Orta',30,45,4,'Karnıyarık','Karnıyarık','Karnıyarık (Split-Belly Eggplant)',
[('patlican','Patlıcan','Eggplant','4','pc'),('kiyma','Dana Kıyma','Ground Beef','250','g'),('sogan','Soğan','Onion','1','pc'),('domates','Domates','Tomatoes','2','pc'),('biber','Yeşil Biber','Green Peppers','4','pc'),('sarimsak','Sarımsak','Garlic','2','clove'),('salca','Domates Salçası','Tomato Paste','1','tbsp')],
[('knife',900,'Patlıcanı Soyup Tuzlama','Patlıcanları alacalı soyun, tuzlu suda 15 dakika bekletip acısını çıkarın ve iyice kurulayın.','Peel and Salt the Eggplants','Peel the eggplants in stripes, soak in salted water for 15 minutes to remove bitterness, then pat dry.','Kurulamayı atlarsanız kızartırken yağı çeker.','Skipping the drying makes them soak up oil.'),
('pan',600,'Patlıcanı Kızartma','Patlıcanları kızgın yağda her yüzü altın rengi olana kadar kızartıp kağıt havlu üzerinde süzün.','Fry the Eggplants','Fry the eggplants in hot oil until golden on all sides and drain on paper towels.','',''),
('pan',600,'Kıymalı İç','Soğanı kavurun, kıymayı ve sarımsağı ekleyip suyunu çekene kadar pişirin; salça ve doğranmış domatesi katın.','Meat Filling','Sauté the onion, add the beef and garlic and cook until the juices evaporate, then add tomato paste and chopped tomato.','',''),
('oven',1800,'Doldurma ve Fırın','Patlıcanları boyuna yarıp iç harcı doldurun, üstüne domates dilimi ve biber koyup sulu tepsiye dizin; 190°C fırında 25-30 dakika pişirin.','Stuff and Bake','Slit the eggplants lengthwise, stuff with the filling, top with a tomato slice and pepper, set in a tray with a little water and bake at 190°C for 25-30 minutes.','','')])

t('tr_hunkar','Hünkar Beğendi','Ana Yemek','Zor',30,60,4,'Hünkâr_beğendi','Hünkâr Beğendi','Hünkâr Beğendi (Sultan\'s Delight)',
[('et','Dana Kuşbaşı','Beef Cubes','500','g'),('patlican','Patlıcan','Eggplants','4','pc'),('tereyagi','Tereyağı','Butter','3','tbsp'),('un','Un','Flour','2','tbsp'),('sut','Süt','Milk','1','cup'),('peynir','Kaşar Peyniri (rendelenmiş)','Grated Kashar Cheese','100','g'),('sogan','Soğan','Onion','1','pc')],
[('pot',2400,'Eti Pişirme','Eti soğanla yağda mühürleyin, salça ve sıcak su ekleyip kapağı kapalı yumuşayana kadar yaklaşık 40 dakika pişirin.','Stew the Beef','Sear the beef with the onion, add tomato paste and hot water, cover and cook about 40 minutes until tender.','',''),
('oven',900,'Patlıcanı Közleme','Patlıcanları ocakta veya fırında kabuğu kararana kadar közleyin, soyup limonlu suda bekletin, sıkıp ince doğrayın.','Char the Eggplants','Char the eggplants over a flame or in the oven, peel, rest in lemon water, squeeze and chop finely.','Limonlu su patlıcanın kararmasını önler.','Lemon water keeps the flesh from browning.'),
('pot',480,'Beğendi','Tereyağında unu 1 dakika kavurun, sütü azar azar ekleyin, kıvam alınca patlıcanı ve peyniri katıp pürüzsüz olana kadar karıştırın.','Make the Purée','Cook flour in butter for 1 minute, whisk in the milk gradually, then add eggplant and cheese and stir until smooth.','',''),
('plate',120,'Servis','Sıcak beğendiyi tabağa yayıp ortasına et yemeğini koyun.','Serve','Spread the hot purée on a plate and place the beef stew in the centre.','','')])

t('tr_menemen','Geleneksel Menemen','Kahvaltılık','Kolay',10,15,2,'Menemen_(dish)','Menemen','Menemen',
[('yumurta','Yumurta','Eggs','3','pc'),('domates','Domates','Tomatoes','3','pc'),('biber','Yeşil Sivri Biber','Green Peppers','2','pc'),('tereyagi','Tereyağı','Butter','1','tbsp'),('tuz','Tuz','Salt','1','pinch')],
[('knife',180,'Doğrama','Biberleri ince halka, domatesleri küçük küp doğrayın.','Chop','Slice the peppers into thin rings and dice the tomatoes small.','',''),
('pan',300,'Sebzeleri Pişirme','Tereyağında biberleri 2 dakika soteleyin, domatesleri ekleyip suyunu çekene kadar pişirin.','Cook the Vegetables','Sauté the peppers in butter for 2 minutes, add tomatoes and cook until their liquid reduces.','',''),
('pan',150,'Yumurta','Yumurtaları sosun üzerine kırın, tuzlayıp ocakta çok hafif karıştırın; yumuşak kıvamda ocaktan alın.','Add the Eggs','Crack the eggs over the sauce, salt, and stir gently; take off the heat while still soft.','Yumurta tavada pişmeye devam eder; erken alın.','Eggs keep cooking in the hot pan; remove them early.')])

t('tr_kurufasulye','Güveçte Kuru Fasulye','Ana Yemek','Orta',15,90,4,'Kuru_fasulye','Kuru Fasulye','Kuru Fasulye (White Bean Stew)',
[('fasulye','Kuru Fasulye','Dried White Beans','2','cup'),('sogan','Soğan','Onion','1','pc'),('salca','Salça','Tomato and Pepper Paste','1','tbsp'),('tereyagi','Tereyağı','Butter','2','tbsp'),('et','Kuşbaşı Et (isteğe bağlı)','Beef Cubes (optional)','200','g')],
[('bowl',28800,'Islatma','Fasulyeyi akşamdan bol suda ıslatın, sabah suyunu dökün.','Soak','Soak the beans overnight in plenty of water and drain in the morning.','',''),
('pot',600,'Ön Haşlama','Fasulyeyi yeni suyla kaynatın, 5 dakika sonra suyunu atıp yeniden taze sıcak su ekleyin.','Pre-boil','Boil the beans, discard the water after 5 minutes and cover with fresh hot water.','',''),
('pot',4200,'Pişirme','Tereyağında soğanı ve salçayı kavurup fasulyeye ekleyin; kısık ateşte yumuşayana kadar 1 saat pişirin, tuzu sonda ekleyin.','Simmer','Fry onion and paste in butter, add to the beans and simmer about 1 hour until soft; salt at the end.','Tuzu erken katarsanız fasulye sert kalır.','Early salt keeps the beans hard.')])

t('tr_kofte','Izgara Kasap Köfte','Ana Yemek','Kolay',20,12,4,'Köfte','Izgara Köfte','Grilled Turkish Meatballs (Izgara Köfte)',
[('kiyma','Dana Kıyma','Ground Beef','500','g'),('sogan','Soğan','Onion','1','pc'),('ekmek','Bayat Ekmek İçi','Stale Bread Crumb','2','tbsp'),('baharat','Kimyon ve Karabiber','Cumin and Black Pepper','1','tsp'),('tuz','Tuz','Salt','1','tsp')],
[('bowl',600,'Yoğurma','Kıymayı rendelenmiş soğan, ekmek içi, baharat ve tuzla 5 dakika yoğurun; en az 30 dakika dinlendirin.','Knead','Knead the beef with grated onion, bread, spices and salt for 5 minutes, then rest at least 30 minutes.','Dinlenen harç daha iyi bağlanır.','Resting helps the mixture bind.'),
('plate',180,'Şekil','Ceviz büyüklüğünde parçalar alıp yassı köfteler şekillendirin.','Shape','Take walnut-sized pieces and shape them into flat patties.','',''),
('grill',540,'Izgara','Kızgın ızgarada veya tavada her yüzü 4 dakika pişirin; sık çevirmeyin.','Grill','Cook on a hot grill or pan 4 minutes per side; avoid flipping repeatedly.','','')])

t('tr_sutlac','Fırın Sütlaç','Tatlı','Kolay',10,60,6,'Sütlaç','Fırın Sütlaç','Fırın Sütlaç (Baked Rice Pudding)',
[('sut','Süt','Milk','1','l'),('pirinc','Pirinç','Rice','0.5','cup'),('seker','Toz Şeker','Sugar','0.75','cup'),('nisasta','Pirinç Unu veya Nişasta','Rice Flour or Starch','1','tbsp'),('vanilya','Vanilya','Vanilla','1','pc')],
[('pot',900,'Pirinci Haşlama','Pirinci 1.5 bardak suda yumuşayana kadar pişirin.','Cook the Rice','Cook the rice in 1.5 cups of water until very soft.','',''),
('pot',900,'Süt ve Şeker','Sütü ve şekeri ekleyin, 15 dakika kaynatın; nişastayı soğuk sütle açıp katarak koyulaştırın.','Add Milk and Sugar','Add the milk and sugar, simmer 15 minutes and thicken with starch dissolved in cold milk.','',''),
('oven',900,'Fırınlama','Güveçlere paylaştırıp 220°C’de üstü kızarana kadar 10-15 dakika fırınlayın veya üstten ızgara açın.','Bake','Divide into bowls and bake at 220°C for 10-15 minutes, or grill, until the top browns.','Üstü kızarana kadar gözünüzü ayırmayın.','Watch closely as the top browns.')])

t('tr_ezogelin','Geleneksel Ezogelin','Çorba','Kolay',10,35,4,'Ezogelin_soup','Ezogelin Çorbası','Ezogelin Soup',
[('mercimek','Kırmızı Mercimek','Red Lentils','1','cup'),('bulgur','Bulgur','Bulgur','2','tbsp'),('pirinc','Pirinç','Rice','1','tbsp'),('sogan','Soğan','Onion','1','pc'),('salca','Salça','Tomato Paste','1','tbsp'),('nane','Nane ve Pul Biber','Mint and Chili Flakes','1','tsp')],
[('pot',420,'Kavurma','Soğanı yağda kavurup salçayı ekleyin, 1 dakika karıştırın.','Fry the Base','Fry the onion in oil, add the paste and stir 1 minute.','',''),
('pot',1500,'Pişirme','Mercimek, bulgur, pirinç ve 6 bardak sıcak su ekleyip malzemeler yumuşayana kadar 25 dakika pişirin.','Cook','Add lentils, bulgur, rice and 6 cups hot water and cook 25 minutes until soft.','',''),
('pan',90,'Sos','Tereyağında nane ve pul biberi köpürtüp çorbaya gezdirin.','Finish','Sizzle mint and chili flakes in butter and drizzle over the soup.','','')])

t('tr_revani','Cevizli Revani','Tatlı','Orta',20,35,8,'Revani','Revani','Revani (Semolina Syrup Cake)',
[('irmik','İrmik','Semolina','1','cup'),('un','Un','Flour','1','cup'),('yumurta','Yumurta','Eggs','4','pc'),('seker','Şeker','Sugar','1','cup'),('yogurt','Yoğurt','Yogurt','1','cup'),('ceviz','Ceviz','Walnuts','0.5','cup')],
[('whisk',420,'Hamur','Yumurta ve şekeri açılana kadar çırpın, yoğurdu, irmiği, unu ve kabartma tozunu ekleyin.','Batter','Whisk eggs and sugar until pale, then mix in yogurt, semolina, flour and baking powder.','',''),
('oven',2100,'Pişirme','Yağlı tepsiye dökün, 180°C’de 30-35 dakika üstü kızarana kadar pişirin.','Bake','Pour into an oiled tray and bake at 180°C for 30-35 minutes until golden.','',''),
('pot',600,'Şerbet','Şeker, su ve limonu 10 dakika kaynatıp soğutun; sıcak revaniye soğuk şerbet dökün, cevizle süsleyin.','Syrup','Boil sugar, water and lemon 10 minutes and cool; pour the cold syrup over the hot cake and top with walnuts.','Sıcak kek – soğuk şerbet kuralı.','Hot cake, cold syrup.')])

t('tr_coban','Geleneksel Çoban Salatası','Salata','Çok Kolay',10,0,4,'Shepherd\'s_salad','Çoban Salatası','Çoban Salatası (Shepherd\'s Salad)',
[('domates','Domates','Tomatoes','4','pc'),('salatalik','Salatalık','Cucumbers','3','pc'),('biber','Yeşil Biber','Green Pepper','2','pc'),('sogan','Kuru Soğan','Onion','1','pc'),('maydanoz','Maydanoz','Parsley','0.5','bunch'),('zeytinyagi','Zeytinyağı','Olive Oil','3','tbsp'),('limon','Limon','Lemon','1','pc')],
[('knife',300,'Doğrama','Domates, salatalık ve biberi aynı boyda küçük küpler halinde doğrayın, maydanozu ince kıyın.','Chop','Dice the tomatoes, cucumbers and peppers to the same small size and finely chop the parsley.','',''),
('bowl',120,'Soğanı Hazırlama','Soğanı ince doğrayıp tuzla ovun, soğuk suda durulayın; sert tadı gider.','Prep the Onion','Chop the onion finely, rub with salt and rinse in cold water to soften its bite.','',''),
('bowl',60,'Sos ve Servis','Zeytinyağı, limon ve tuzla karıştırıp hemen servis edin.','Dress and Serve','Toss with olive oil, lemon and salt and serve right away.','Tuzu en son ekleyin; yoksa sebzeler su salar.','Salt at the end or the vegetables weep.')])

t('tr_mercimek','Süzme Kırmızı Mercimek','Çorba','Çok Kolay',10,30,4,'Lentil_soup','Süzme Mercimek Çorbası','Turkish Red Lentil Soup',
[('mercimek','Kırmızı Mercimek','Red Lentils','1','cup'),('sogan','Soğan','Onion','1','pc'),('havuc','Havuç','Carrot','1','pc'),('patates','Patates','Potato','1','pc'),('tereyagi','Tereyağı','Butter','2','tbsp'),('limon','Limon','Lemon','1','pc')],
[('pot',420,'Sebzeler','Soğan, havuç ve patatesi tereyağında 5 dakika çevirin.','Sweat Vegetables','Stir the onion, carrot and potato in butter for 5 minutes.','',''),
('pot',1500,'Pişirme','Yıkanmış mercimeği ve 6 bardak sıcak suyu ekleyip her şey ezilecek kadar yumuşayana dek 25 dakika pişirin.','Cook','Add rinsed lentils and 6 cups hot water and cook 25 minutes until everything is soft.','',''),
('blender',120,'Pürüzsüz Yapma ve Servis','Blenderdan geçirin, tuzlayıp limon sıkarak servis edin.','Blend and Serve','Blend until smooth, season and finish with a squeeze of lemon.','','')])
