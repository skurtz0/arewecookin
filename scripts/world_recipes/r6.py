from r1 import add, R
def d(id,cuis,cov,cat,dif,p,k,sv,wiki,tr,en,ing,steps):
    ings=[tuple(x.split('|')) for x in ing.split(';')]
    st=[tuple(x.split('|'))+('','') if len(x.split('|'))==6 else tuple(x.split('|')) for x in steps.split(';;')]
    st=[(a,int(b),c,dd,e,f,*(rest if rest else ('','')) ) for (a,b,c,dd,e,f,*rest) in st]
    add(id,cuis,cat,dif,p,k,sv,wiki,tr,en,ings,st); R[-1]['cov']=cov
T='Türk Mutfağı'
d('tr_terbiyeli','Türk Mutfağı','Terbiyeli Köfte','Ana Yemek','Orta',30,40,4,'Köfte','Terbiyeli Köfte','Terbiyeli Köfte (Meatballs in Lemon-Egg Sauce)',
'kiyma|Dana Kıyma|Ground Beef|400|g;pirinc|Pirinç|Rice|0.5|cup;yumurta|Yumurta|Egg|1|pc;limon|Limon Suyu|Lemon Juice|3|tbsp;un|Un|Flour|2|tbsp',
'bowl|600|Köfte Harcı|Kıyma, ıslatılmış pirinç, soğan ve tuzu yoğurup ceviz büyüklüğünde toplar yapın, una bulayın.|Meatball Mix|Knead beef, soaked rice, onion and salt, shape into walnut-size balls and roll in flour.;;pot|1500|Haşlama|Kaynayan tuzlu suya köfteleri bırakıp kısık ateşte 25 dakika pişirin.|Simmer|Drop the meatballs into boiling salted water and simmer 25 minutes.;;whisk|300|Terbiye|Yumurta, limon suyu ve 1 kepçe sıcak çorbayı çırpıp kazana yavaşça ekleyin; 2 dakika daha ısıtın, kaynatmayın.|Egg-Lemon Liaison|Whisk egg, lemon and a ladle of hot broth, stir into the pot slowly and heat 2 more minutes without boiling.|Kaynatırsanız yumurta kesilir.|Boiling will curdle the egg.')
d('tr_alinazik','Türk Mutfağı','Ali Nazik Kebabı','Ana Yemek','Orta',25,35,4,'Ali Nazik','Ali Nazik Kebabı','Ali Nazik Kebab',
'patlican|Patlıcan|Eggplants|4|pc;yogurt|Süzme Yoğurt|Strained Yogurt|1|cup;sarimsak|Sarımsak|Garlic|2|clove;kiyma|Kuzu Kıyma|Ground Lamb|300|g;tereyagi|Tereyağı|Butter|2|tbsp',
'pan|900|Patlıcanı Közleme|Patlıcanları közleyip soyun, ince doğrayın.|Char the Eggplant|Char and peel the eggplants and chop them finely.;;bowl|120|Yoğurtlu Yatak|Patlıcanı ezilmiş sarımsak ve yoğurtla karıştırın.|Yogurt Bed|Mix the eggplant with crushed garlic and yogurt.;;pan|600|Kıyma ve Servis|Kıymayı tereyağında kavurup patlıcan yatağının üzerine yerleştirin.|Meat and Serve|Fry the lamb in butter and place it on the eggplant bed.')
d('tr_cokertme','Türk Mutfağı','Bodrum Çökertme Kebabı','Ana Yemek','Orta',20,35,4,'Çökertme kebabı','Çökertme Kebabı','Çökertme Kebab',
'et|Dana Bonfile|Beef Tenderloin|400|g;patates|Patates|Potatoes|3|pc;yogurt|Yoğurt|Yogurt|1|cup;sarimsak|Sarımsak|Garlic|2|clove;tereyagi|Tereyağı|Butter|2|tbsp',
'knife|600|Hazırlık|Eti ince şeritler, patatesi çıta çıta doğrayın.|Prep|Cut the beef into thin strips and the potatoes into matchsticks.;;pan|900|Patates|Patatesleri kızgın yağda altın renge gelene kadar kızartın.|Fry Potatoes|Fry the potatoes in hot oil until golden.;;pan|600|Et ve Servis|Eti tereyağında hızlıca sote edin; patatesin üzerine koyup sarımsaklı yoğurtla servis edin.|Sear and Serve|Quickly sauté the beef in butter, put over the potatoes and serve with garlic yogurt.')
d('tr_kuzuincik','Türk Mutfağı','Kuzu İncik','Ana Yemek','Orta',20,150,4,'Lamb shank','Kuzu İncik','Braised Lamb Shank',
'incik|Kuzu İncik|Lamb Shanks|4|pc;sogan|Soğan|Onion|2|pc;havuc|Havuç|Carrot|2|pc;salca|Salça|Tomato Paste|1|tbsp',
'pan|600|Mühürleme|İncikleri kızgın yağda her yüzü kızarana kadar mühürleyin.|Sear|Sear the shanks in hot oil until browned all over.;;pot|600|Sebze|Soğan, havuç ve salçayı ekleyip 5 dakika kavurun, sıcak su ile kapatın.|Vegetables|Add onion, carrot and paste, cook 5 minutes and cover with hot water.;;oven|9000|Fırın|Kapalı kapta 160°C fırında 2,5 saat pişirin; et kemikten ayrılmalı.|Braise|Braise covered at 160°C for 2.5 hours until the meat falls off the bone.')
d('tr_iskender','Türk Mutfağı','Bursa İskender Kebabı','Ana Yemek','Orta',25,25,4,'İskender kebap','İskender Kebap','İskender Kebab',
'et|Dönerlik Et|Sliced Doner Meat|400|g;pide|Pide Ekmeği|Pide Bread|1|pc;domates|Domates Sosu|Tomato Sauce|1|cup;tereyagi|Tereyağı|Butter|3|tbsp;yogurt|Yoğurt|Yogurt|1|cup',
'oven|300|Ekmek|Pideyi küp doğrayıp fırında kızartın.|Bread|Cube the pide and toast it in the oven.;;pan|480|Et|Dönerlik eti tavada kızartın, ekmeğin üstüne dizin.|Meat|Fry the doner meat and layer it over the bread.;;pan|240|Sos ve Servis|Domates sosunu sıcak dökün, üzerine eritilmiş tereyağı gezdirip yoğurtla servis edin.|Sauce and Serve|Pour hot tomato sauce, drizzle with melted butter and serve with yogurt.')
d('tr_sekerpare','Türk Mutfağı','Şekerpare','Tatlı','Orta',30,35,8,'Şekerpare','Şekerpare','Şekerpare',
'tereyagi|Tereyağı|Butter|125|g;un|Un|Flour|2|cup;irmik|İrmik|Semolina|0.5|cup;seker|Toz Şeker|Sugar|0.5|cup;fistik|Fındık|Hazelnuts|16|pc',
'bowl|600|Hamur|Tereyağı, şeker, un ve irmiği yoğurup yumuşak hamur yapın.|Dough|Knead butter, sugar, flour and semolina into a soft dough.;;oven|1500|Pişirme|Ceviz büyüklüğünde toplar yapıp ortasına fındık bastırın; 180°C fırında 25 dakika pişirin.|Bake|Shape walnut-size balls, press a hazelnut on each and bake at 180°C for 25 minutes.;;pot|600|Şerbet|Su ve şekeri kaynatıp soğuk şerbeti sıcak şekerpareye dökün.|Syrup|Boil sugar and water, pour cold syrup over hot şekerpare.')
d('tr_sarayhallebi','Türk Mutfağı','Saray Muhallebisi','Tatlı','Kolay',10,25,6,'Muhallebi','Saray Muhallebisi','Muhallebi (Milk Pudding)',
'sut|Süt|Milk|1|l;seker|Şeker|Sugar|0.75|cup;nisasta|Pirinç Unu|Rice Flour|4|tbsp;vanilya|Vanilya|Vanilla|1|tsp',
'whisk|120|Karıştırma|Pirinç ununu soğuk sütün bir kısmında açın.|Mix|Dissolve rice flour in some cold milk.;;pot|900|Pişirme|Kalan süt ve şekerle karışımı sürekli karıştırarak koyulaşana kadar pişirin.|Cook|Cook with remaining milk and sugar, stirring, until thick.;;plate|7200|Soğutma|Kaselere paylaştırıp buzdolabında 2 saat soğutun.|Chill|Pour into bowls and chill for 2 hours.')
d('tr_ekmekkadayifi','Türk Mutfağı','Vişneli Ekmek Kadayıfı','Tatlı','Orta',20,40,6,'Ekmek kadayıfı','Ekmek Kadayıfı','Ekmek Kadayıfı (Bread Dessert)',
'ekmek|Kadayıf Ekmeği|Kadayıf Bread|6|pc;seker|Şeker|Sugar|1.5|cup;visne|Vişne|Sour Cherries|1|cup;kaymak|Kaymak|Clotted Cream|200|g',
'pot|600|Şerbet|Şeker, su ve vişneyi kaynatın.|Syrup|Boil sugar, water and cherries.;;oven|1800|Pişirme|Ekmekleri şerbetle ıslatın, tepsiye dizip 180°C fırında 25 dakika pişirin.|Soak and Bake|Soak the bread, arrange in a tray and bake at 180°C for 25 minutes.;;plate|120|Servis|Kaymakla servis edin.|Serve|Serve with clotted cream.')
d('tr_kulahkaymak','Türk Mutfağı','Antep Fıstıklı Katmer','Tatlı','Zor',40,15,4,'Katmer','Antep Fıstıklı Katmer','Katmer (Pistachio Pastry)',
'un|Un|Flour|2|cup;fistik|Antep Fıstığı|Pistachios|150|g;kaymak|Kaymak|Clotted Cream|100|g;tereyagi|Tereyağı|Butter|3|tbsp',
'bowl|1800|Hamur|Un, su ve tuzla hamuru yoğurup 30 dakika dinlendirin.|Dough|Knead flour, water and salt and rest 30 minutes.;;knife|600|Açma|Hamuru çok ince açıp kaymak ve fıstıkla doldurun, katlayın.|Roll|Roll very thin, fill with cream and pistachios and fold.;;pan|480|Pişirme|Tereyağında iki tarafı çıtır olana kadar pişirin.|Cook|Fry in butter until both sides are crisp.')
d('tr_kremali_mantar_corba','Türk Mutfağı','Kremalı Dağ Mantarı','Çorba','Kolay',10,25,4,'Cream of mushroom soup','Kremalı Mantar Çorbası','Cream of Mushroom Soup',
'mantar|Mantar|Mushrooms|300|g;un|Un|Flour|2|tbsp;sut|Süt|Milk|2|cup;krema|Krema|Cream|0.5|cup;tereyagi|Tereyağı|Butter|2|tbsp',
'pan|480|Mantar|Mantarları tereyağında suyunu çekene kadar kavurun.|Mushrooms|Fry mushrooms in butter until their liquid evaporates.;;pot|600|Çorba|Un ve sütü ekleyip kıvam alana kadar pişirin.|Soup|Add flour and milk and cook until thickened.;;blender|120|Blender|Pürüzsüz olana kadar çekin, krema ekleyin.|Blend|Blend smooth and stir in the cream.')
d('tr_tavuk_corba','Türk Mutfağı','Terbiyeli Tavuk Çorbası','Çorba','Kolay',10,35,4,'Chicken soup','Terbiyeli Tavuk Çorbası','Chicken Soup with Lemon-Yogurt Liaison',
'tavuk|Tavuk Göğsü|Chicken Breast|250|g;un|Un|Flour|2|tbsp;yogurt|Yoğurt|Yogurt|0.5|cup;yumurta|Yumurta Sarısı|Egg Yolk|1|pc',
'pot|1500|Haşlama|Tavuğu suda haşlayıp didikleyin.|Boil|Boil the chicken and shred it.;;pot|480|Çorba|Un ve tereyağını kavurup tavuk suyunu ekleyin.|Soup|Cook flour in butter and add the stock.;;whisk|180|Terbiye|Yoğurt ve yumurta sarısını çırpıp sıcak çorbayla ısıtarak ekleyin.|Liaison|Whisk yogurt and yolk, temper with hot soup and stir in.')
d('tr_arpa_sehriye','Türk Mutfağı','Arpa Şehriyeli Çorba','Çorba','Kolay',5,25,4,'Soup','Arpa Şehriyeli Çorba','Orzo Soup',
'sehriye|Arpa Şehriye|Orzo|0.5|cup;domates|Domates Salçası|Tomato Paste|1|tbsp;tereyagi|Tereyağı|Butter|1|tbsp',
'pan|180|Kavurma|Şehriyeyi tereyağında kızartın, salçayı ekleyin.|Toast|Toast the orzo in butter and add tomato paste.;;pot|1200|Pişirme|Sıcak suyu ekleyip 15 dakika pişirin.|Cook|Add hot water and cook 15 minutes.;;plate|60|Servis|Tuz ve kırmızı biberle servis edin.|Serve|Season and serve hot.')
d('tr_misocorba','Japonya','Geleneksel Miso Çorbası','Çorba','Çok Kolay',5,10,2,'Miso soup','Miso Çorbası (味噌汁)','Miso Soup (味噌汁)',
'dashi|Dashi|Dashi Stock|2|cup;miso|Miso|Miso Paste|2|tbsp;tofu|Tofu|Tofu|100|g;sogan|Taze Soğan|Scallion|1|pc',
'pot|300|Dashi|Dashi\'yi kaynama noktasına getirip tofuyu ekleyin.|Dashi|Bring dashi almost to a boil and add tofu.;;bowl|60|Miso|Misoyu biraz dashi ile ezip tencereye katın; kaynatmayın.|Miso|Dissolve miso in a little dashi and add; do not boil.;;plate|30|Servis|Taze soğanla servis edin.|Serve|Top with scallion.')
d('tr_lazanya','İtalya','Klasik Fırın Lazanya','Ana Yemek','Orta',40,60,6,'Lasagne','Lazanya','Lasagne',
'lazanya|Lazanya Yaprağı|Lasagne Sheets|250|g;kiyma|Dana Kıyma|Ground Beef|400|g;domates|Domates Sosu|Tomato Sauce|2|cup;beshamel|Beşamel|Béchamel|2|cup;peynir|Parmesan|Parmesan|80|g',
'pan|900|Ragu|Kıymayı kavurup domates sosuyla 15 dakika pişirin.|Ragù|Brown the beef and simmer with tomato sauce 15 minutes.;;bowl|600|Katmanlar|Tepsiye sos, yaprak, beşamel ve peynir sırayla katlayın.|Layer|Layer sauce, sheets, béchamel and cheese in a tray.;;oven|2400|Pişirme|190°C fırında 40 dakika pişirip 10 dakika dinlendirin.|Bake|Bake at 190°C for 40 minutes and rest 10.')
d('tr_risotto','İtalya','Kremalı Mantarlı Risotto','Ana Yemek','Orta',10,35,3,'Risotto','Mantarlı Risotto','Mushroom Risotto',
'pirinc|Arborio Pirinç|Arborio Rice|1|cup;mantar|Mantar|Mushrooms|200|g;stock|Sebze Suyu|Vegetable Stock|4|cup;peynir|Parmesan|Parmesan|50|g',
'pan|480|Mantar|Mantarları kavurup kenara alın.|Mushrooms|Sauté the mushrooms and set aside.;;pot|1200|Pirinç|Pirinci kavurup sıcak suyu kepçe kepçe ekleyerek 18 dakika karıştırın.|Rice|Toast rice and add hot stock ladle by ladle for 18 minutes.;;plate|120|Bitirme|Mantar ve parmesanı katın.|Finish|Stir in mushrooms and parmesan.')
d('tr_ramen','Japonya','Tavuklu Japon Rameni','Ana Yemek','Orta',15,30,2,'Ramen','Tavuklu Ramen (ラーメン)','Chicken Ramen (ラーメン)',
'noodle|Ramen Eriştesi|Ramen Noodles|200|g;tavuk|Tavuk Göğsü|Chicken Breast|150|g;soya|Soya Sosu|Soy Sauce|2|tbsp;yumurta|Yumurta|Egg|2|pc;stock|Tavuk Suyu|Chicken Stock|3|cup',
'pot|600|Et suyu|Tavuk suyuna soya sosu ekleyip tavuğu pişirin.|Broth|Simmer chicken in the stock with soy sauce.;;pot|420|Erişte|Eriştesi ve haşlanmış yumurtayı hazırlayın.|Noodles|Cook the noodles and soft-boil the eggs.;;bowl|90|Servis|Kaseye erişte, et suyu, tavuk ve yumurta koyun.|Assemble|Assemble noodles, broth, chicken and egg in a bowl.')
d('tr_padthai2','Tayland','Geleneksel Pad Thai','Ana Yemek','Kolay',10,15,2,'Pad thai','Pad Thai (ผัดไทย)','Pad Thai',
'noodle|Pirinç Eriştesi|Rice Noodles|200|g;yumurta|Yumurta|Egg|2|pc;fistik|Fıstık|Peanuts|3|tbsp',
'bowl|600|Islatma|Erişteyi ılık suda yumuşatın.|Soak|Soak noodles in warm water.;;pan|300|Wok|Erişte ve yumurtayı wokta çevirin.|Wok|Toss noodles and egg in a hot wok.;;plate|60|Servis|Fıstıkla servis edin.|Serve|Top with peanuts.')
d('tr_tacos','Meksika','Kıymalı Çıtır Taco','Ana Yemek','Kolay',15,15,4,'Taco','Kıymalı Taco','Beef Tacos',
'kiyma|Kıyma|Ground Beef|300|g;tortilla|Taco Kabuğu|Taco Shells|8|pc;domates|Domates|Tomato|2|pc;peynir|Çedar|Cheddar|80|g',
'pan|480|Kıyma|Kıymayı baharatla kavurun.|Beef|Brown the beef with spices.;;knife|180|Hazırlık|Domates ve peyniri doğrayın.|Prep|Dice tomato and cheese.;;plate|120|Servis|Kabuklara doldurun.|Fill|Fill the shells.')
d('tr_ratatouille','Fransa','Geleneksel Fırın Ratatouille','Ana Yemek','Orta',20,50,4,'Ratatouille','Ratatouille','Ratatouille',
'patlican|Patlıcan|Eggplant|1|pc;kabak|Kabak|Zucchini|2|pc;domates|Domates|Tomatoes|3|pc;biber|Biber|Pepper|1|pc',
'knife|600|Dilimleme|Sebzeleri ince halka kesin.|Slice|Slice the vegetables thinly.;;bowl|300|Dizme|Domates sosunun üzerine spiral dizin.|Arrange|Arrange in a spiral over tomato sauce.;;oven|2700|Pişirme|180°C fırında 45 dakika pişirin.|Bake|Bake at 180°C for 45 minutes.')
d('tr_paella','İspanya','Deniz Mahsullü Paella','Ana Yemek','Zor',20,40,4,'Paella','Paella','Seafood Paella',
'pirinc|Bomba Pirinç|Bomba Rice|1.5|cup;karides|Karides|Shrimp|200|g;midye|Midye|Mussels|200|g;safran|Safran|Saffron|1|pinch',
'pan|600|Sofrito|Zeytinyağında domates ve sarımsağı pişirin.|Sofrito|Cook tomato and garlic in olive oil.;;pan|1500|Pirinç|Pirinç ve safranlı sıcak suyu ekleyip karıştırmadan pişirin.|Rice|Add rice and saffron stock and cook without stirring.;;plate|300|Deniz mahsulü|Karides ve midyeyi üstüne dizip 5 dakika pişirin.|Seafood|Place shrimp and mussels on top and cook 5 minutes.')
d('tr_chilicc','Meksika','Meksika Usulü Chili con Carne','Ana Yemek','Kolay',15,60,4,'Chili con carne','Chili con Carne','Chili con Carne',
'kiyma|Kıyma|Ground Beef|400|g;fasulye|Kırmızı Fasulye|Kidney Beans|1|cup;domates|Domates|Tomatoes|3|pc;biber|Pul Biber|Chili|1|tsp',
'pan|480|Kıyma|Kıymayı soğanla kavurun.|Brown|Brown beef with onion.;;pot|3000|Pişirme|Domates ve fasulyeyi ekleyip 50 dakika pişirin.|Simmer|Add tomato and beans, simmer 50 minutes.;;plate|60|Servis|Sıcak servis edin.|Serve|Serve hot.')
d('tr_tiramisu','İtalya','Geleneksel Tiramisu','Tatlı','Orta',25,0,6,'Tiramisu','Tiramisu','Tiramisu',
'mascarpone|Mascarpone|Mascarpone|250|g;yumurta|Yumurta|Eggs|3|pc;kahve|Soğuk Kahve|Cold Coffee|1|cup;bisku|Savoiardi Bisküvi|Ladyfingers|200|g',
'whisk|480|Krema|Sarıları şekerle çırpıp mascarpone ekleyin.|Cream|Whisk yolks with sugar and fold in mascarpone.;;bowl|300|Katman|Bisküvileri kahveye batırıp kremayla katlayın.|Layer|Dip biscuits in coffee and layer with cream.;;plate|21600|Dinlendirme|En az 6 saat soğutup kakaolayın.|Chill|Chill at least 6 hours and dust with cocoa.')
d('tr_pannacotta','İtalya','Vanilyalı Panna Cotta','Tatlı','Kolay',10,10,4,'Panna cotta','Panna Cotta','Panna Cotta',
'krema|Krema|Cream|2|cup;seker|Şeker|Sugar|3|tbsp;jelatin|Jelatin|Gelatin|2|tsp',
'pot|300|Isıtma|Krema ve şekeri ısıtıp jelatini eritin.|Heat|Warm cream and sugar and dissolve gelatin.;;bowl|120|Dökme|Kalıplara paylaştırın.|Pour|Pour into molds.;;plate|14400|Soğutma|4 saat buzdolabında bekletin.|Chill|Chill for 4 hours.')
d('tr_churros','Meksika','Tarçınlı Meksika Churros','Tatlı','Orta',15,15,4,'Churro','Churros','Churros',
'un|Un|Flour|1|cup;su|Su|Water|1|cup;seker|Şeker|Sugar|2|tbsp;tarcin|Tarçın|Cinnamon|1|tsp',
'pot|240|Hamur|Su ve unu kaynatıp hamur yapın.|Dough|Cook water and flour into a dough.;;pan|480|Kızartma|Şekil verip kızgın yağda kızartın.|Fry|Pipe and fry in hot oil.;;plate|60|Şekerleme|Tarçınlı şekere bulayın.|Coat|Roll in cinnamon sugar.')
d('tr_magnolia','Türk Mutfağı','Çilekli Magnolia','Tatlı','Kolay',20,15,6,'Magnolia','Çilekli Magnolia','Strawberry Magnolia',
'sut|Süt|Milk|2|cup;krema|Krema|Cream|1|cup;bisku|Bisküvi|Biscuits|150|g;cilek|Çilek|Strawberries|200|g',
'pot|600|Krema|Süt, şeker ve unla muhallebi pişirin.|Custard|Cook milk, sugar and flour into custard.;;bowl|300|Katman|Bisküvi, muhallebi ve çileği katlayın.|Layer|Layer biscuits, custard and strawberries.;;plate|7200|Soğutma|2 saat soğutun.|Chill|Chill 2 hours.')
d('tr_profiterol','Fransa','Profiterol','Tatlı','Zor',30,35,6,'Profiterole','Profiterol','Profiteroles',
'un|Un|Flour|1|cup;tereyagi|Tereyağı|Butter|100|g;yumurta|Yumurta|Eggs|3|pc;cikolata|Çikolata|Chocolate|150|g',
'pot|420|Hamur|Su, yağ ve unla hamur pişirip yumurtaları katın.|Choux|Cook water, butter, flour and beat in eggs.;;oven|1800|Pişirme|200°C fırında şişene kadar pişirin.|Bake|Bake at 200°C until puffed.;;pot|300|Sos|Çikolata sosuyla servis edin.|Sauce|Serve with chocolate sauce.')
d('tr_cheesecake','ABD','Limonlu Cheesecake','Tatlı','Orta',25,50,8,'Cheesecake','Limonlu Cheesecake','Lemon Cheesecake',
'peynir|Krem Peynir|Cream Cheese|500|g;bisku|Bisküvi|Biscuits|200|g;limon|Limon|Lemon|1|pc;yumurta|Yumurta|Eggs|3|pc',
'bowl|300|Taban|Bisküvi ve tereyağını karıştırıp tabana bastırın.|Base|Press biscuit and butter into the pan.;;whisk|480|Krem|Peynir, yumurta ve limonu çırpıp dökün.|Filling|Whisk cheese, eggs and lemon and pour over.;;oven|3000|Pişirme|160°C fırında 45 dakika pişirip soğutun.|Bake|Bake at 160°C for 45 minutes and chill.')
d('tr_pankek','ABD','Yulaflı Pankek','Kahvaltılık','Kolay',10,15,2,'Pancake','Yulaflı Pankek','Oat Pancakes',
'yulaf|Yulaf|Oats|1|cup;yumurta|Yumurta|Egg|1|pc;sut|Süt|Milk|1|cup;muz|Muz|Banana|1|pc',
'bowl|180|Hamur|Tüm malzemeleri karıştırın.|Batter|Mix all ingredients.;;pan|420|Pişirme|Tavada iki yüzü altın olana kadar pişirin.|Cook|Cook until golden on both sides.;;plate|60|Servis|Meyve ile servis edin.|Serve|Serve with fruit.')
d('tr_cilbir','Türk Mutfağı','Çılbır (Yoğurtlu Poşe Yumurta)','Kahvaltılık','Kolay',5,10,2,'Çılbır','Çılbır','Çılbır (Poached Eggs with Yogurt)',
'yumurta|Yumurta|Eggs|4|pc;yogurt|Sarımsaklı Yoğurt|Garlic Yogurt|1|cup;tereyagi|Tereyağı|Butter|2|tbsp;biber|Pul Biber|Chili Flakes|1|tsp',
'pot|240|Poşe|Yumurtaları kaynayan sirkeli suda poşe edin.|Poach|Poach the eggs in simmering vinegared water.;;pan|60|Yağ|Tereyağında pul biberi eritin.|Butter|Melt chili flakes in butter.;;plate|60|Servis|Yoğurdun üzerine yumurta ve yağı koyun.|Serve|Put eggs and butter over the yogurt.')
d('tr_shakshuka','Türk Mutfağı','Menemen Usulü Shakshuka','Kahvaltılık','Kolay',10,20,2,'Shakshouka','Şakşuka (Shakshuka)','Shakshuka',
'yumurta|Yumurta|Eggs|4|pc;domates|Domates|Tomatoes|4|pc;biber|Biber|Peppers|2|pc;kimyon|Kimyon|Cumin|1|tsp',
'pan|480|Sos|Biber ve domatesi kimyonla pişirin.|Sauce|Cook peppers and tomatoes with cumin.;;pan|480|Yumurta|Çukurlar açıp yumurta kırın.|Eggs|Make wells and crack the eggs in.;;plate|60|Servis|Ekmekle servis edin.|Serve|Serve with bread.')
d('tr_gozleme','Türk Mutfağı','Peynirli Çıtır Gözleme','Kahvaltılık','Kolay',20,10,4,'Gözleme','Peynirli Gözleme','Gözleme',
'un|Un|Flour|2|cup;peynir|Beyaz Peynir|Feta|150|g;maydanoz|Maydanoz|Parsley|1|bunch',
'bowl|900|Hamur|Hamuru yoğurup dinlendirin.|Dough|Knead and rest the dough.;;knife|240|Açma|İnce açıp peynirle doldurun.|Roll|Roll thin and fill with cheese.;;pan|300|Pişirme|Sacda iki tarafı pişirin.|Cook|Cook both sides on a griddle.')
d('tr_pizza','İtalya','İtalyan Pizza Margherita','Pratik','Orta',90,12,2,'Pizza Margherita','Pizza Margherita','Pizza Margherita',
'un|Un|Flour|300|g;domates|Domates Sosu|Tomato Sauce|0.5|cup;peynir|Mozzarella|Mozzarella|150|g;feslegen|Fesleğen|Basil|1|bunch',
'bowl|3600|Hamur|Hamuru yoğurup 1 saat mayalayın.|Dough|Knead and let rise 1 hour.;;knife|300|Açma|İnce açıp sos ve peynir koyun.|Top|Stretch thin and add sauce and cheese.;;oven|720|Pişirme|250°C fırında 10 dakika pişirin.|Bake|Bake at 250°C for 10 minutes.')
d('tr_gnocchi','İtalya','Patatesli Gnocchi','Pratik','Orta',30,10,3,'Gnocchi','Gnocchi','Potato Gnocchi',
'patates|Patates|Potatoes|500|g;un|Un|Flour|150|g;yumurta|Yumurta|Egg|1|pc',
'pot|1800|Patates|Patatesleri haşlayıp ezin.|Potatoes|Boil and mash the potatoes.;;bowl|480|Hamur|Un ve yumurta ile yoğurup kesin.|Dough|Knead with flour and egg and cut.;;pot|180|Pişirme|Yüzene kadar haşlayın.|Cook|Boil until they float.')
d('tr_pide','Türk Mutfağı','Kıymalı Pide','Hamur İşi','Orta',90,15,3,'Pide','Kıymalı Pide','Kıymalı Pide',
'un|Un|Flour|300|g;kiyma|Kıyma|Ground Beef|200|g;sogan|Soğan|Onion|1|pc',
'bowl|3600|Hamur|Hamuru yoğurup mayalayın.|Dough|Knead and let rise.;;pan|300|Harç|Kıymayı soğanla kavurun.|Filling|Cook beef and onion.;;oven|900|Pişirme|Doldurup 230°C fırında pişirin.|Bake|Fill and bake at 230°C.')
d('tr_lahmacun','Türk Mutfağı','Ev Yapımı Fındık Lahmacun','Hamur İşi','Orta',60,10,4,'Lahmacun','Lahmacun','Lahmacun',
'un|Un|Flour|300|g;kiyma|Kıyma|Ground Meat|250|g;domates|Domates|Tomato|2|pc',
'bowl|2400|Hamur|Hamuru yoğurup dinlendirin.|Dough|Knead and rest.;;bowl|300|Harç|Kıyma, domates ve baharatı karıştırın.|Topping|Mix meat, tomato and spices.;;oven|480|Pişirme|İnce açıp 250°C fırında pişirin.|Bake|Roll thin and bake at 250°C.')
d('tr_gyoza','Japonya','Gyoza (Japon Mantısı)','Hamur İşi','Orta',40,10,4,'Gyoza','Gyoza (餃子)','Gyoza (餃子)',
'un|Gyoza Hamuru|Gyoza Wrappers|20|pc;kiyma|Domuz/Tavuk Kıyma|Ground Pork or Chicken|200|g;lahana|Lahana|Cabbage|100|g',
'bowl|600|İç|Kıyma, lahana ve soya sosunu karıştırın.|Filling|Mix meat, cabbage and soy.;;knife|900|Doldurma|Hamura doldurup kıvırın.|Fold|Fill and pleat.;;pan|420|Pişirme|Tavada tabanı kızarıp buharda pişirin.|Fry|Pan-fry then steam.')
d('tr_sezar','İtalya','Tavuklu Sezar Salata','Salata','Kolay',15,10,2,'Caesar salad','Tavuklu Sezar Salata','Chicken Caesar Salad',
'marul|Marul|Romaine|1|pc;tavuk|Tavuk|Chicken|200|g;peynir|Parmesan|Parmesan|40|g;ekmek|Kruton|Croutons|1|cup',
'pan|480|Tavuk|Tavuğu ızgarada pişirin.|Chicken|Grill the chicken.;;bowl|180|Sos|Sos ile marulu karıştırın.|Dress|Toss lettuce with dressing.;;plate|60|Servis|Tavuk ve kruton ekleyin.|Serve|Top with chicken and croutons.')
d('tr_tabule','Lübnan','Tabule (Bulgur Salatası)','Salata','Kolay',20,0,4,'Tabbouleh','Tabule (تبولة)','Tabbouleh (تبولة)',
'bulgur|İnce Bulgur|Fine Bulgur|0.5|cup;maydanoz|Maydanoz|Parsley|3|bunch;domates|Domates|Tomatoes|3|pc;limon|Limon|Lemon|2|pc',
'bowl|600|Bulgur|Bulguru limon suyunda ıslatın.|Soak|Soak bulgur in lemon juice.;;knife|600|Doğrama|Maydanoz ve domatesi ince doğrayın.|Chop|Chop parsley and tomato finely.;;bowl|60|Karıştırma|Zeytinyağı ile karıştırın.|Toss|Toss with olive oil.')
d('tr_grek','Yunanistan','Geleneksel Grek Salatası','Salata','Çok Kolay',10,0,2,'Greek salad','Yunan Salatası','Greek Salad',
'domates|Domates|Tomatoes|3|pc;salatalik|Salatalık|Cucumber|1|pc;peynir|Feta|Feta|100|g;zeytin|Zeytin|Olives|10|pc',
'knife|300|Doğrama|Sebzeleri iri doğrayın.|Chop|Chop vegetables coarsely.;;bowl|60|Sos|Zeytinyağı ve kekik ekleyin.|Dress|Add olive oil and oregano.;;plate|60|Peynir|Feta ekleyip servis edin.|Serve|Top with feta.')
d('tr_babagannus','Lübnan','Köz Patlıcanlı Babagannuş','Salata','Kolay',15,20,4,'Baba ghanoush','Babagannuş (بابا غنوج)','Baba Ganoush',
'patlican|Patlıcan|Eggplants|3|pc;tahin|Tahin|Tahini|2|tbsp;limon|Limon|Lemon|1|pc;sarimsak|Sarımsak|Garlic|1|clove',
'oven|1200|Közleme|Patlıcanları közleyin.|Char|Char the eggplants.;;bowl|300|Ezme|Etini tahinle ezin.|Mash|Mash the flesh with tahini.;;plate|60|Servis|Limon ve zeytinyağı ile servis edin.|Serve|Serve with lemon and olive oil.')
