--
-- PostgreSQL database dump
--

\restrict 7TSvsPHpjf3wEE1UQGgjc927yNHOHW7bQms3fXRf5dAAUrVwCCm0auEwhdAGvQd

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: tower_sessions; Type: SCHEMA; Schema: -; Owner: dbuser
--

CREATE SCHEMA tower_sessions;


ALTER SCHEMA tower_sessions OWNER TO dbuser;

--
-- Name: hero_image(bigint); Type: FUNCTION; Schema: public; Owner: dbuser
--

CREATE FUNCTION public.hero_image(tax_id bigint DEFAULT 1) RETURNS text
    LANGUAGE sql
    AS $$WITH RECURSIVE node_tree AS (
    SELECT id, parent_id, category_id
    FROM taxonomy
    WHERE id = tax_id 
    UNION ALL
    SELECT t.id, t.parent_id, t.category_id
    FROM taxonomy t
    JOIN node_tree n ON t.parent_id = n.id
),
linked_images as (
	select max(i.image) image , creature_id 
	from image i
	join creature_images ci on ci.image_id = i.id
	group by creature_id
)
SELECT image
FROM node_tree nt
JOIN creature c on c.genus_id = nt.id
JOIN linked_images iii ON c.id = iii.creature_id
JOIN category cc ON nt.category_id = cc.id
where cc.hierarchy  = 5
ORDER BY random() 
LIMIT 1;
$$;


ALTER FUNCTION public.hero_image(tax_id bigint) OWNER TO dbuser;

--
-- Name: simple(bigint); Type: FUNCTION; Schema: public; Owner: dbuser
--

CREATE FUNCTION public.simple(image_id bigint DEFAULT 0) RETURNS text
    LANGUAGE sql
    AS $$
select image from image where id = image_id
$$;


ALTER FUNCTION public.simple(image_id bigint) OWNER TO dbuser;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: category; Type: TABLE; Schema: public; Owner: dbuser
--

CREATE TABLE public.category (
    id integer CONSTRAINT animals_category_id_not_null NOT NULL,
    name character varying(64) CONSTRAINT animals_category_name_not_null NOT NULL,
    hierarchy integer CONSTRAINT animals_category_hierarchy_not_null NOT NULL
);


ALTER TABLE public.category OWNER TO dbuser;

--
-- Name: animals_category_id_seq; Type: SEQUENCE; Schema: public; Owner: dbuser
--

CREATE SEQUENCE public.animals_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.animals_category_id_seq OWNER TO dbuser;

--
-- Name: animals_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbuser
--

ALTER SEQUENCE public.animals_category_id_seq OWNED BY public.category.id;


--
-- Name: creature; Type: TABLE; Schema: public; Owner: dbuser
--

CREATE TABLE public.creature (
    id integer CONSTRAINT animals_creature_id_not_null NOT NULL,
    name character varying(64) CONSTRAINT animals_creature_name_not_null NOT NULL,
    scientific_name character varying(64) CONSTRAINT animals_creature_scientific_name_not_null NOT NULL,
    genus_id bigint CONSTRAINT animals_creature_genus_id_not_null NOT NULL,
    slug character varying(64) CONSTRAINT animals_creature_slug_not_null NOT NULL
);


ALTER TABLE public.creature OWNER TO dbuser;

--
-- Name: animals_creature_id_seq; Type: SEQUENCE; Schema: public; Owner: dbuser
--

CREATE SEQUENCE public.animals_creature_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.animals_creature_id_seq OWNER TO dbuser;

--
-- Name: animals_creature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbuser
--

ALTER SEQUENCE public.animals_creature_id_seq OWNED BY public.creature.id;


--
-- Name: creature_images; Type: TABLE; Schema: public; Owner: dbuser
--

CREATE TABLE public.creature_images (
    id integer CONSTRAINT animals_creature_images_id_not_null NOT NULL,
    creature_id bigint CONSTRAINT animals_creature_images_creature_id_not_null NOT NULL,
    image_id bigint CONSTRAINT animals_creature_images_image_id_not_null NOT NULL
);


ALTER TABLE public.creature_images OWNER TO dbuser;

--
-- Name: animals_creature_images_id_seq; Type: SEQUENCE; Schema: public; Owner: dbuser
--

CREATE SEQUENCE public.animals_creature_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.animals_creature_images_id_seq OWNER TO dbuser;

--
-- Name: animals_creature_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbuser
--

ALTER SEQUENCE public.animals_creature_images_id_seq OWNED BY public.creature_images.id;


--
-- Name: creature_locations; Type: TABLE; Schema: public; Owner: dbuser
--

CREATE TABLE public.creature_locations (
    id integer CONSTRAINT animals_creature_locations_id_not_null NOT NULL,
    creature_id bigint CONSTRAINT animals_creature_locations_creature_id_not_null NOT NULL,
    location_id bigint CONSTRAINT animals_creature_locations_location_id_not_null NOT NULL
);


ALTER TABLE public.creature_locations OWNER TO dbuser;

--
-- Name: animals_creature_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: dbuser
--

CREATE SEQUENCE public.animals_creature_locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.animals_creature_locations_id_seq OWNER TO dbuser;

--
-- Name: animals_creature_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbuser
--

ALTER SEQUENCE public.animals_creature_locations_id_seq OWNED BY public.creature_locations.id;


--
-- Name: image; Type: TABLE; Schema: public; Owner: dbuser
--

CREATE TABLE public.image (
    id integer CONSTRAINT animals_image_id_not_null NOT NULL,
    iheight integer,
    iwidth integer,
    image text
);


ALTER TABLE public.image OWNER TO dbuser;

--
-- Name: animals_image_id_seq; Type: SEQUENCE; Schema: public; Owner: dbuser
--

CREATE SEQUENCE public.animals_image_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.animals_image_id_seq OWNER TO dbuser;

--
-- Name: animals_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbuser
--

ALTER SEQUENCE public.animals_image_id_seq OWNED BY public.image.id;


--
-- Name: location; Type: TABLE; Schema: public; Owner: dbuser
--

CREATE TABLE public.location (
    id integer CONSTRAINT animals_location_id_not_null NOT NULL,
    name character varying(64) CONSTRAINT animals_location_name_not_null NOT NULL,
    slug character varying(64) CONSTRAINT animals_location_slug_not_null NOT NULL
);


ALTER TABLE public.location OWNER TO dbuser;

--
-- Name: animals_location_id_seq; Type: SEQUENCE; Schema: public; Owner: dbuser
--

CREATE SEQUENCE public.animals_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.animals_location_id_seq OWNER TO dbuser;

--
-- Name: animals_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbuser
--

ALTER SEQUENCE public.animals_location_id_seq OWNED BY public.location.id;


--
-- Name: location_images; Type: TABLE; Schema: public; Owner: dbuser
--

CREATE TABLE public.location_images (
    id integer CONSTRAINT animals_location_images_id_not_null NOT NULL,
    location_id bigint CONSTRAINT animals_location_images_location_id_not_null NOT NULL,
    image_id bigint CONSTRAINT animals_location_images_image_id_not_null NOT NULL
);


ALTER TABLE public.location_images OWNER TO dbuser;

--
-- Name: animals_location_images_id_seq; Type: SEQUENCE; Schema: public; Owner: dbuser
--

CREATE SEQUENCE public.animals_location_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.animals_location_images_id_seq OWNER TO dbuser;

--
-- Name: animals_location_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbuser
--

ALTER SEQUENCE public.animals_location_images_id_seq OWNED BY public.location_images.id;


--
-- Name: page; Type: TABLE; Schema: public; Owner: dbuser
--

CREATE TABLE public.page (
    id integer CONSTRAINT animals_page_id_not_null NOT NULL,
    slug character varying(32) CONSTRAINT animals_page_slug_not_null NOT NULL,
    title character varying(128) CONSTRAINT animals_page_title_not_null NOT NULL,
    content text CONSTRAINT animals_page_content_not_null NOT NULL,
    image_id bigint CONSTRAINT animals_page_image_id_not_null NOT NULL
);


ALTER TABLE public.page OWNER TO dbuser;

--
-- Name: animals_page_id_seq; Type: SEQUENCE; Schema: public; Owner: dbuser
--

CREATE SEQUENCE public.animals_page_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.animals_page_id_seq OWNER TO dbuser;

--
-- Name: animals_page_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbuser
--

ALTER SEQUENCE public.animals_page_id_seq OWNED BY public.page.id;


--
-- Name: taxonomy; Type: TABLE; Schema: public; Owner: dbuser
--

CREATE TABLE public.taxonomy (
    id integer CONSTRAINT animals_taxonomy_id_not_null NOT NULL,
    category_id bigint CONSTRAINT animals_taxonomy_category_id_not_null NOT NULL,
    name character varying(64) CONSTRAINT animals_taxonomy_name_not_null NOT NULL,
    parent_id integer CONSTRAINT animals_taxonomy_parent_id_not_null NOT NULL,
    slug character varying(64) CONSTRAINT animals_taxonomy_slug_not_null NOT NULL
);


ALTER TABLE public.taxonomy OWNER TO dbuser;

--
-- Name: animals_taxonomy_id_seq; Type: SEQUENCE; Schema: public; Owner: dbuser
--

CREATE SEQUENCE public.animals_taxonomy_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.animals_taxonomy_id_seq OWNER TO dbuser;

--
-- Name: animals_taxonomy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbuser
--

ALTER SEQUENCE public.animals_taxonomy_id_seq OWNED BY public.taxonomy.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: dbuser
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    pass_hash text NOT NULL
);


ALTER TABLE public.users OWNER TO dbuser;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: dbuser
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO dbuser;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbuser
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: session; Type: TABLE; Schema: tower_sessions; Owner: dbuser
--

CREATE TABLE tower_sessions.session (
    id text NOT NULL,
    data bytea NOT NULL,
    expiry_date timestamp with time zone NOT NULL
);


ALTER TABLE tower_sessions.session OWNER TO dbuser;

--
-- Name: category id; Type: DEFAULT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.category ALTER COLUMN id SET DEFAULT nextval('public.animals_category_id_seq'::regclass);


--
-- Name: creature id; Type: DEFAULT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.creature ALTER COLUMN id SET DEFAULT nextval('public.animals_creature_id_seq'::regclass);


--
-- Name: creature_images id; Type: DEFAULT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.creature_images ALTER COLUMN id SET DEFAULT nextval('public.animals_creature_images_id_seq'::regclass);


--
-- Name: creature_locations id; Type: DEFAULT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.creature_locations ALTER COLUMN id SET DEFAULT nextval('public.animals_creature_locations_id_seq'::regclass);


--
-- Name: image id; Type: DEFAULT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.image ALTER COLUMN id SET DEFAULT nextval('public.animals_image_id_seq'::regclass);


--
-- Name: location id; Type: DEFAULT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.location ALTER COLUMN id SET DEFAULT nextval('public.animals_location_id_seq'::regclass);


--
-- Name: location_images id; Type: DEFAULT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.location_images ALTER COLUMN id SET DEFAULT nextval('public.animals_location_images_id_seq'::regclass);


--
-- Name: page id; Type: DEFAULT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.page ALTER COLUMN id SET DEFAULT nextval('public.animals_page_id_seq'::regclass);


--
-- Name: taxonomy id; Type: DEFAULT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.taxonomy ALTER COLUMN id SET DEFAULT nextval('public.animals_taxonomy_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: dbuser
--

COPY public.category (id, name, hierarchy) FROM stdin;
1	kingdom	0
2	phylum	1
3	class	2
4	order	3
5	family	4
6	genus	5
\.


--
-- Data for Name: creature; Type: TABLE DATA; Schema: public; Owner: dbuser
--

COPY public.creature (id, name, scientific_name, genus_id, slug) FROM stdin;
1	Cooper’s Hawk	Accipiter cooperii	6	coopers-hawk
2	Ferruginous Hawk	Buteo regalis	8	ferruginous-hawk
3	Goshawk	Accipiter gentilis	6	goshawk
8	Grey Mouse Lemur	Microcebus murinus	21	grey-mouse-lemur
9	Arctic Hare	Lepus Arcticus	24	arctic-hare
10	Hare	Lepus	24	hare
11	Snowshoe Hare	Lepus americanus	24	snowshoe-hare
12	Aardwolf	Proteles cristata	27	aardwolf
13	Arctic Wolf	Canus Lupus Arcticus	29	arctic-wolf
14	Czechoslovakian Wolfdog	Canis lupus	29	czechoslovakian-wolfdog
15	Eurasian Wolf	Canis lupus lupus	29	eurasian-wolf
16	Irish WolfHound	Canis Lupus	29	irish-wolfhound
17	Mackenzie Wolf	Canis lupus occidentalis	29	mackenzie-wolf
18	Maned Wolf	Chyrsocyon brachyurus	30	maned-wolf
19	Red Wolf	Canis lupus rufus	29	red-wolf
20	Wolf Eel	Anarrhichthys ocellatus	34	wolf-eel
21	Wolf Snake	Lycodon capucinus	38	wolf-snake
22	Canadian Horse	Equus ferus caballus	41	canadian-horse
23	Devils Coach Horse Beetle	Ocypus olens	44	devils-coach-horse-beetle
24	Horse	Equus caballus	41	horse
25	Seahorse	Hippocampus	47	seahorse
26	Tennessee Walker Horse	Equus ferus	41	tennessee-walker-horse
27	Basking Shark	Cetorhinus Maximus	51	basking-shark
28	Blue Shark	Prionace glauca	54	blue-shark
29	Bonnethead Shark	Sphyrna tiburo	56	bonnethead-shark
30	Bull Shark	Carcharhinus Leucas	57	bull-shark
31	Frilled Shark	Chlamydoselachus anguineus	60	frilled-shark
32	Goblin Shark	Mitsukurina owstoni	62	goblin-shark
33	Great White Shark	Carcharodon carcharias	64	great-white-shark
34	Greenland Shark	Somniosus microcephalus	67	greenland-shark
35	Grey Reef Shark	Carcharhinus Amblyrhynchos	57	grey-reef-shark
36	Horn Shark	Heterodontus francisci	70	horn-shark
37	Megamouth Shark	Megachasma pelagios	72	megamouth-shark
38	Nurse Shark	Ginglymostoma cirratum	75	nurse-shark
39	Porbeagle Shark	Lamna nasus	76	porbeagle-shark
40	Salmon Shark	Lamna ditropis	76	salmon-shark
41	Spinner Shark	Carcharhinus brevipinna	57	spinner-shark
42	Tiger Shark	Galeocerdo Cuvier	77	tiger-shark
43	Viper shark (dogfish)	Trigonognathus kabeyai	79	viper-shark-dogfish
44	Whale Shark	Rhincodon Typus	81	whale-shark
45	Zebra Shark	Stegostoma Fasciatum	83	zebra-shark
46	Amur Leopard	Panthera pardus orientalis	85	amur-leopard
47	Clouded Leopard	Neofelis nebulosa	86	clouded-leopard
48	Jackson’s Chameleon	Trioceros jacksonii	88	jacksons-chameleon
49	Leopard	Panthera pardus	85	leopard
50	Leopard Cat	Prionailurus bengalensis	89	leopard-cat
51	Leopard Gecko	Eublepharis macularius	91	leopard-gecko
52	Leopard Seal	Hydrurga Leptonyx	93	leopard-seal
53	Leopard Tortoise	Stigmochelys pardalis	96	leopard-tortoise
54	Snow Leopard	Panthera uncia	85	snow-leopard
55	Cow	Bos Taurus	99	cow
56	Steller’s Sea Cow	Hydrodamalis Gigas	102	stellers-sea-cow
57	Peregrine Falcon	Falco peregrinus	105	peregrine-falcon
58	Eastern Bluebird	Sialia sialis	108	eastern-bluebird
59	Frigatebird	Fregata	111	frigatebird
60	Mountain Bluebird	Sialia currucoides	108	mountain-bluebird
61	Red-Billed Quelea Bird	Quelea quelea	113	red-billed-quelea-bird
62	Red-winged blackbird	Agelaius phoeniceus	115	red-winged-blackbird
63	Ruby-Throated Hummingbird	Archilochus colubris	118	ruby-throated-hummingbird
64	Umbrellabird	Cephalopterus	120	umbrellabird
65	Weaver Bird	Ploceus cucullatus	121	weaver-bird
66	Jackrabbit	Lepus californicus	24	jackrabbit
67	Rabbit	Oryctolagus cuniculus	122	rabbit
68	Black Widow Spider	Latrodectus	126	black-widow-spider
69	Common House Spider	Parasteatoda tepidariorum	128	common-house-spider
70	False Widow Spider	Steatoda grossa	130	false-widow-spider
71	Joro Spider	Trichonephila clavata	132	joro-spider
72	Redback Spider	Latrodectus hasselti	126	redback-spider
73	Spider Ball Python	Python regius	134	spider-ball-python
74	Spider Monkey	Simia Paniscus	136	spider-monkey
75	Spider-Tailed Horned Viper	Pseudocerastes urarachnoides	138	spider-tailed-horned-viper
76	Woodlouse Spider	Dysdera crocata	140	woodlouse-spider
77	Writing Spider	Argiope aurantia	141	writing-spider
78	Asiatic Black Bear	Ursus tibetanus	143	asiatic-black-bear
79	Bear	Ursidae	143	bear
80	Bearded Dragon	Pogona Vitticeps	145	bearded-dragon
81	Brown Bear	Ursus arctos	143	brown-bear
82	Giant Panda Bear	Ailuropoda melanoleuca	146	giant-panda-bear
83	Grizzly Bear	Ursus Arctos Horriblis	143	grizzly-bear
84	North American Black Bear	Ursus americanus	143	north-american-black-bear
85	Polar Bear	Ursus maritimus	143	polar-bear
86	Spectacled Bear	Tremarctos Ornatus	147	spectacled-bear
6	Tarantula Hawk	Pepsis albocincta	14	tarantula-hawk
4	Harris Hawk	Parabuteo unicinctus	9	harris-hawk
7	Cactus Mouse	Peromyscus erimicus	18	cactus-mouse
87	Sun Bear	Helarctos malayanus	148	sun-bear
88	Teddy Bear Hamster	Mesocricetus auratus	149	teddy-bear-hamster
89	Mexican Mole Lizard	Bipes biporus	151	mexican-mole-lizard
90	Mole Snake	Pseudaspis cana	153	mole-snake
91	Naked Mole Rat	Heterocephalus glaber	155	naked-mole-rat
92	Star-nosed mole	Condylura cristata	158	star-nosed-mole
93	Christmas Island Red Crab	Gecarcoidea natalis	162	christmas-island-red-crab
94	Crab-Eating Macaque	Macaca Fascicularis	164	crab-eating-macaque
95	Crabeater Seal	Lobodon carcinophaga	166	crabeater-seal
96	Jonah Crab	Cancer borealis	168	jonah-crab
97	King Crab	Lopholithodes Mandtii	170	king-crab
98	Rock Crab	Cancer productus	168	rock-crab
99	Snow Crab	C. opilio	172	snow-crab
100	Ostrich	Struthio camelus	175	ostrich
101	African Bush Elephant	Loxodonta africana africana	178	african-bush-elephant
102	African Forest Elephant	Loxodonta cyclotis	178	african-forest-elephant
103	Asian Elephant	Elephas maximus	179	asian-elephant
104	Borneo Elephant	Elephas maximus borneensis	179	borneo-elephant
105	Elephant Seal	Mirounga	180	elephant-seal
106	Elephant Shrew	Elephantulus	183	elephant-shrew
107	Indian Elephant	Elephas maximus indicus	179	indian-elephant
108	Sri Lankan Elephant	Elephas Maximus Maximus	179	sri-lankan-elephant
109	Sumatran Elephant	Elephas Maximus Sumatranus	179	sumatran-elephant
110	Black Rhinoceros	Diceros Bicornis	185	black-rhinoceros
111	Indian Rhinoceros	Rhinoceros Unicornis	186	indian-rhinoceros
112	Javan Rhinoceros	Rhinoceros Sondaicus	186	javan-rhinoceros
113	Sumatran Rhinoceros	Dicerorhinus Sumatrensis	187	sumatran-rhinoceros
114	White Rhinoceros	Ceratotherium simum	188	white-rhinoceros
115	Capybara	Hydrochoerus hydrochaeris	190	hydrochoerus-hydrochaeris
116	Otter	Lutra Canadensis	192	lutra-canadensis
117	River Otter	Lontra canadensis	194	lontra-canadensis
118	Sea Otter	Enhydra Lutris	195	enhydra-lutris
119	Platypus	Ornithorhynchus anatinus	198	ornithorhynchus-anatinus
120	Monarch Butterfly	Danaus plexippus	201	danaus-plexippus
121	Peacock Butterfly	Aglais io	202	aglais-io
122	Purple Emperor Butterfly	Apatura iris	203	apatura-iris
123	White Butterfly	Pieris rapae	205	pieris-rapae
124	Saiga	Saiga tatarica	206	saiga-tatarica
125	Alpine Goat	Capra aegagrus hircus	207	capra-aegagrus-hircus
126	Serval	Leptailurus serval	208	leptailurus-serval
127	Narwhal	Monodon monoceros	211	monodon-monoceros
128	Okapi	Okapia johnstoni	213	okapia-johnstoni
133	Flamingo	Flamingo	222	flamingo
5	Sparrowhawk	Accipiter nisus	6	sparrowhawk
\.


--
-- Data for Name: creature_images; Type: TABLE DATA; Schema: public; Owner: dbuser
--

COPY public.creature_images (id, creature_id, image_id) FROM stdin;
1	50	118
2	50	119
3	50	120
4	88	121
5	88	122
6	88	123
7	77	124
8	77	125
9	77	126
10	83	127
11	83	128
12	83	129
13	82	130
14	82	131
15	82	132
16	81	133
17	81	134
18	81	135
19	79	136
20	79	137
21	79	138
22	55	139
23	55	140
24	55	141
25	54	142
26	54	144
27	53	145
28	53	146
29	53	147
30	65	148
31	65	149
32	65	150
33	9	151
34	9	152
35	9	153
36	10	154
37	10	155
38	10	156
39	11	157
40	11	158
41	11	159
42	27	160
43	27	161
44	27	162
45	28	163
46	28	164
47	28	165
48	29	166
49	29	167
50	29	168
51	30	169
52	30	170
53	30	171
54	31	172
55	31	173
56	31	174
57	32	175
58	32	176
59	32	177
60	33	178
61	33	179
62	33	180
63	34	181
64	34	182
65	34	183
66	35	184
67	35	185
68	35	186
69	36	187
70	36	188
71	36	189
72	37	190
73	37	191
74	37	192
75	38	193
76	38	194
77	38	195
78	39	196
79	39	197
80	39	198
81	40	199
82	40	200
83	40	201
84	41	202
85	41	203
86	41	204
87	42	205
88	42	206
89	42	207
90	43	208
91	43	209
92	43	210
93	44	211
94	44	212
95	44	213
96	45	214
97	45	215
98	45	216
99	89	217
100	89	218
101	89	219
102	90	220
103	90	221
104	90	222
105	91	223
106	91	224
107	91	225
108	92	226
109	92	227
110	92	228
111	93	229
112	93	230
113	93	231
114	94	232
115	94	233
116	94	234
117	95	235
118	95	236
119	95	237
120	96	238
122	96	240
123	97	241
124	97	242
125	97	243
126	98	244
127	98	245
128	98	246
129	99	247
130	99	248
131	99	249
132	58	250
133	58	252
134	58	255
135	59	256
136	59	257
137	59	262
140	60	267
144	60	271
145	60	272
147	61	277
149	62	280
155	61	287
156	61	288
158	62	290
159	62	291
160	63	292
161	63	293
162	63	294
163	64	303
164	64	304
165	64	308
167	78	310
168	78	311
169	78	312
170	80	313
171	80	314
172	80	315
173	84	316
174	84	317
175	84	318
176	85	319
177	85	320
179	86	322
180	86	323
181	86	324
182	87	325
183	87	326
184	87	327
185	7	328
186	7	329
187	7	330
188	8	331
189	8	332
190	8	333
191	100	334
192	100	335
193	100	336
194	101	337
195	101	338
196	101	339
197	102	340
198	102	341
199	102	342
200	103	343
201	103	344
202	103	345
203	104	346
204	104	347
205	104	348
206	105	349
207	105	350
208	105	351
209	106	352
210	106	353
211	106	354
212	107	355
213	107	356
214	107	357
215	108	358
216	108	359
217	108	360
218	109	361
219	109	362
220	109	363
221	110	364
222	110	365
223	110	366
224	111	367
225	111	368
226	111	369
227	112	370
228	112	371
229	112	372
230	113	373
231	113	374
232	113	375
233	114	376
234	114	377
235	114	378
236	46	379
237	46	380
238	46	381
239	54	382
240	49	384
241	49	385
242	49	386
243	12	387
244	12	388
245	12	389
246	13	390
247	13	391
248	13	392
249	68	393
250	68	394
251	68	395
252	22	396
253	22	397
254	22	398
255	47	399
256	47	400
257	47	401
258	69	402
259	69	403
260	69	404
261	1	405
262	1	406
263	1	407
266	14	410
267	23	411
268	23	412
269	23	413
270	76	414
271	76	415
272	76	416
273	75	417
274	75	418
275	75	419
276	74	420
277	74	421
278	74	422
279	73	423
280	73	424
281	73	425
282	72	426
284	72	428
285	71	429
286	71	430
287	71	431
288	70	432
289	70	433
290	70	434
291	67	435
292	67	436
293	67	437
294	66	438
295	66	439
296	66	440
297	57	441
298	57	442
299	57	443
300	56	444
301	56	445
302	56	446
303	52	447
304	52	448
305	52	449
306	51	450
307	51	451
308	51	452
309	48	453
310	48	454
311	48	455
312	26	456
313	26	457
314	26	458
318	24	462
319	24	463
320	24	464
321	21	465
322	21	466
323	21	467
324	20	468
325	20	469
326	20	470
327	19	471
328	19	472
329	19	473
330	18	474
331	18	475
332	18	476
333	17	477
334	17	478
335	17	479
337	16	481
338	16	482
339	15	483
340	15	484
341	15	485
342	6	486
343	6	487
344	6	488
345	5	489
346	5	490
347	5	491
348	4	492
349	4	493
350	4	494
351	3	495
352	3	496
353	3	497
354	2	498
355	2	499
356	2	500
359	14	503
360	72	504
361	96	515
365	115	519
366	115	520
367	115	521
368	116	522
369	116	523
370	116	524
371	117	525
372	117	526
373	117	527
374	118	528
375	118	529
376	118	530
377	85	531
378	119	532
379	119	533
380	119	534
381	123	535
382	123	536
383	123	537
384	122	538
385	122	539
386	122	540
387	121	541
388	121	542
389	121	543
390	120	544
391	120	545
392	120	546
393	124	547
394	124	548
395	124	549
396	125	550
397	125	551
398	125	552
399	126	553
400	126	554
401	126	555
402	127	556
403	127	557
404	127	558
405	128	559
406	128	560
407	128	561
408	14	562
409	25	563
410	25	564
411	25	565
412	133	567
413	133	568
414	133	569
\.


--
-- Data for Name: creature_locations; Type: TABLE DATA; Schema: public; Owner: dbuser
--

COPY public.creature_locations (id, creature_id, location_id) FROM stdin;
98	1	17
99	1	18
100	2	17
101	2	18
102	3	17
103	3	18
104	3	19
105	3	20
106	3	21
107	3	22
108	4	17
109	4	18
110	4	22
111	5	24
112	5	25
113	5	19
114	5	23
115	6	17
116	6	18
117	6	19
118	6	22
119	6	23
120	6	25
121	7	18
122	8	19
123	9	18
124	10	17
125	10	18
126	10	19
127	10	20
128	10	22
129	10	23
130	10	24
131	10	25
132	11	18
133	12	19
134	13	18
136	15	24
137	15	20
138	15	23
139	16	24
140	17	18
141	18	22
142	19	18
149	20	21
150	21	23
151	22	18
152	23	24
153	23	19
154	24	17
155	24	18
156	24	19
157	24	20
158	24	22
159	24	23
160	24	24
161	24	25
162	25	17
163	25	18
164	25	19
165	25	20
166	25	21
167	25	22
168	25	23
169	25	24
170	25	25
171	26	18
172	27	21
173	28	21
174	29	21
175	30	21
178	33	21
179	34	21
180	35	21
181	36	21
182	37	21
183	38	21
184	39	21
185	40	21
186	41	21
187	42	21
188	43	21
189	44	21
190	45	21
191	46	20
192	46	23
193	47	23
194	48	18
195	48	19
197	49	19
198	49	23
199	50	23
200	51	23
201	52	27
202	52	21
203	53	19
204	54	20
205	54	23
206	55	17
207	55	18
208	55	19
209	55	20
210	55	22
211	55	23
212	55	24
213	55	25
215	56	21
216	57	17
217	57	18
218	57	19
219	57	20
220	57	22
221	57	23
222	57	24
223	57	25
224	58	17
225	58	18
226	59	21
227	60	17
228	60	18
229	61	19
230	62	17
231	62	18
232	63	17
233	63	18
234	64	17
235	64	22
236	65	19
237	65	23
238	66	17
239	66	18
240	67	18
241	67	19
242	67	20
243	67	23
244	67	24
245	68	17
246	68	18
247	68	19
248	68	20
249	68	22
250	68	23
251	68	24
252	68	25
253	69	17
254	69	18
255	69	19
256	69	20
257	69	22
258	69	23
259	69	24
260	69	25
261	70	17
262	70	18
263	70	19
264	70	20
265	70	22
266	70	23
267	70	24
268	70	25
269	71	23
270	72	24
271	72	25
272	72	23
273	73	19
274	74	17
275	74	22
276	75	23
277	76	18
278	76	19
279	76	20
280	76	22
281	76	23
282	76	24
283	76	25
284	77	17
285	77	18
286	78	20
287	78	23
288	79	17
289	79	18
290	79	20
291	79	22
292	79	23
293	79	24
295	80	25
296	81	24
297	81	18
298	81	20
299	81	23
300	82	23
301	83	18
302	84	18
303	85	24
304	85	18
305	85	20
306	85	21
308	86	22
309	87	23
310	88	24
311	88	23
312	89	17
313	89	18
314	90	19
315	91	19
316	92	18
317	93	25
318	93	21
319	94	23
320	95	27
321	96	18
322	97	21
323	98	21
324	99	21
325	100	19
326	101	19
327	102	19
328	103	23
329	104	21
330	104	23
331	105	21
332	106	19
333	107	23
334	108	23
335	109	23
336	110	19
337	111	23
338	112	23
339	113	23
340	114	19
341	31	21
342	32	21
343	115	22
344	116	17
345	116	18
346	116	19
347	116	20
348	116	22
349	116	23
350	116	24
351	116	25
352	14	24
353	117	18
354	118	21
355	119	25
356	120	17
357	120	18
358	120	19
359	120	22
360	120	23
361	120	24
362	120	25
363	121	24
364	121	20
365	121	23
366	122	24
367	122	20
368	122	23
369	123	18
370	123	19
371	123	23
372	123	24
373	123	25
374	124	23
376	125	18
380	125	23
381	125	24
382	125	25
383	126	19
385	128	19
386	127	21
398	133	17
399	133	18
400	133	19
401	133	20
402	133	22
403	133	23
404	133	24
\.


--
-- Data for Name: image; Type: TABLE DATA; Schema: public; Owner: dbuser
--

COPY public.image (id, iheight, iwidth, image) FROM stdin;
118	600	450	./animals/asian-leopard-cat-prionailurus-bengalensis-18113660.jpg
119	610	813	./animals/ps_3288418801_2635fd4c2a_b_1453880848.jpg
120	1334	2000	./animals/160813-accb-96758_3bd0c85d.jpg
121	600	800	./animals/1255687315_490_00_800.jpg
122	1066	1600	./animals/Mesocricetus-auratus-criceto-dorato_associazione_mammagatta.jpg
123	548	750	./animals/MesocricetusAuratus.jpg
124	1625	1200	./animals/1200px-Black_and_Yellow_Argiope_-_Argiope_aurantia_-_Merritt_Island_National_Wildlife_Refuge%2C_Florida.jpg
125	1067	1600	./animals/argiope-aurantia-31.jpg
126	1485	986	./animals/argiope-aurantia-32.jpg
127	953	1300	./animals/close-up-of-grizzly-bear-ursus-arctos-horriblis-brooks-river-katmai-BCC8P2.jpg
128	319	450	./animals/grizzly-bear-ursus-arctos-horriblis-la-captura-de-salmon-brooks-river-parque-nacional-katmai-alaska-ee-uu-c2hb0g.jpg
129	1390	866	./animals/grizzly-bear-ursus-arctos-horriblis-female-and-yearling-cub-with-paws-KCNMMH.jpg
130	683	1024	./animals/Ailuropoda_melanoleuca2.jpg
131	1500	1000	./animals/332915-medium.jpg
132	800	1280	./animals/4623.jpg
133	600	800	./animals/d2a2f02b-0729-4ee8-b8db-d8ab0e90b746.jpg
134	853	1280	./animals/1280px-Brown_bear_(Ursus_arctos_arctos)_smiling.jpg
135	405	750	./animals/ursus-arctos-alascensis.jpg
136	732	1024	./animals/5562173781_dc21c30f94_b.jpg
137	776	1040	./animals/ursidae-wikipedia-destine-ours-savant.jpg
138	370	470	./animals/Bear+Ursidae+01.jpg
139	1333	2000	./animals/Bos_taurus_taurus_looking.jpg
140	683	1024	./animals/duPoitou_9085-1024x683.jpg
141	1793	2700	./animals/Bos_taurus_indicus.jpg
142	1330	1995	./animals/776026_c4feffbe62c5448895ee1e3d0d788469~mv2.jpg
144	946	1500	./animals/snow-leopard--panthera-uncia--157528589-5c473a9ec9e77c00016ec625.jpg
145	800	1200	./animals/Stigmochelys-pardalis-Leopard-Tortoise-Prince-Albert-Western-Cape2.jpg
146	376	500	./animals/foto_kenia_stigmochelys_pardalis.jpg
147	1712	2288	./animals/38124.jpg
148	1000	563	./animals/ploceus-cucullatus-1-.jpg
149	700	1023	./animals/49922623282_74dcbb5c21_b.jpg
150	673	600	./animals/ploceus-cucullatus--xxxsnovac_ploceus.jpg
151	1000	1500	./animals/Edmonton_Leporidae2_-JefferyJ-Nichols-User-Arctic-gnome-CC-Att-SA3-Un.jpg
152	700	470	./animals/00064761.jpg
153	639	800	./animals/Arctic_Hare_1.jpg
154	729	750	./animals/LepusCapensis1.jpg
155	968	1000	./animals/europaeus.jpg
156	1600	2400	./animals/Lepus_capensis.jpg
157	866	1024	./animals/iStock_43789952_LARGE-1024x866.jpg
158	823	1318	./animals/50700_orig.jpg
159	792	1080	./animals/Snowshoe-Hare.jpg
160	1358	3334	./animals/Cetorhinus maximus lateral female_0.jpg
161	1333	2000	./animals/Cetorhinus-Maximus-5.jpg
162	926	1220	./animals/Basking_Shark.jpg
163	620	1288	./animals/prionace_glauca_by_topgon-d5o36y2.jpg
164	683	1024	./animals/Prionace_glauca_by_mark_conlin-XL.jpg
165	550	900	./animals/prionace-glauca.jpg
166	428	640	./animals/sphyrna-tiburo-00005.jpg
167	720	1280	./animals/14500_1gRxsPFUum.jpg
168	1493	2560	./animals/requin-marteau-sphyrna-tiburo-aquarium-la-rochelle-header-2560X1493.jpg
169	2912	4376	./animals/REQUIN-BOULEDOGUE.jpg
170	432	650	./animals/CarcharhLeuc2DaveHarasti.jpg
171	698	1050	./animals/bull-shark-carcharhinus-leucas-picture-12725-816100.jpg
172	700	1400	./animals/9fd8db121aa26f0faabb523a42790523.jpg
173	1534	2300	./animals/ChlamydoselachAnguinTePapa.jpg
174	692	1000	./animals/Chlamydoselachus_meeresmuseum_3.jpg
175	1661	2500	./animals/MitsukOwstoni3.jpg
176	998	1500	./animals/Mitsukurina-Owstoni-1.jpg
177	1661	2500	./animals/MitsukOwston3JKFinn.jpg
178	821	2087	./animals/Carcharodon carcharias.jpg
179	1060	1600	./animals/DSC_0733_uxga.jpg
180	1060	1600	./animals/DSC_0260_uxga.jpg
181	900	1600	./animals/requin-du-groenland.jpg
182	1113	1536	./animals/Somniosus-Microcephalus-1536x1113.jpg
183	\N	\N	./animals/1397950461_polyarnaya-akula-somniosus-microcephalus.jpg
184	1334	2005	./animals/CarcharhAmblyrhynchIanShaw.jpg
185	853	1280	./animals/grey-reef-shark-(carcharhinus-amblyrhynchos)-.jpg
186	400	600	./animals/Grey_Reef_Shark_-_Carcharhinus_amblyrhynchos_600.jpg
187	709	1050	./animals/horn-shark-photograph-01071-531460.jpg
188	427	640	./animals/blogger-image-749629910.jpg
189	1496	4338	./animals/0x0_191764-33 Heterodontus francisci - MRI 765mm- lateral.jpg
190	1170	1000	./animals/Megachasma_pelagios_3.jpg
191	768	1024	./animals/gallery_77_13_38036.jpg
192	600	800	./animals/megamouthsharkNOAA.jpg
193	866	1300	./animals/species_8a_582953dfc0b8b.w1300.h866.jpg
194	1180	1796	./animals/Nurse_shark.jpg
195	1350	1800	./animals/nurseshark.jpg
196	912	2000	./animals/Lamna nasus.jpg
197	376	566	./animals/LamnaNasusNMFS.jpg
198	382	620	./animals/NADANDO:+ALAMY.jpg
199	768	1024	./animals/lamna-ditropis.jpg
200	400	600	./animals/ladit_u0.jpg
201	400	850	./animals/Lamna_ditropis_850x400.jpg
202	1325	2000	./animals/Blacktip-Shark-073.jpg
203	600	800	./animals/Carcharhinus-brevipinna.jpg
204	\N	\N	./animals/Spinner-Shark-Carcharhinus-brevipinna-GH-Burgess.jpg
205	851	1280	./animals/Galeocerdo2KevinBryant.jpg
206	768	1024	./animals/galeocerdo-cuvieri.jpg
207	603	907	./animals/Galeocerdo3AlbertKok.jpg
208	300	450	./animals/Trigonognathus_kabeyai_head_2.jpg
209	587	1048	./animals/tubarao-1048x587.jpg
210	675	1200	./animals/CO3WEAGUsAAAR42.jpg
211	997	1500	./animals/RhincodonTypus3ErikSchlogl.jpg
212	577	960	./animals/1-Rhincodon-typus.jpg
213	1183	1778	./animals/RhincodonFGBNMSEckert.jpg
214	426	640	./animals/Stegostoma2RR.jpg
215	1157	1600	./animals/curious-zebra-shark-stegostoma-fasciatum-deep-underwater-tropical-reef-207989383.jpg
216	554	918	./animals/Zebra-Shark-Zebra-Shark-Stegostoma-fasciatum-LEI-DPI-2261.jpg
217	819	1024	./animals/Bipes-Biporus-Wallpaper-1024x819.jpg
218	640	960	./animals/Bipes_biporus-960x640.jpg
219	399	519	./animals/bipes+biporus.jpg
220	1600	2400	./animals/Pseudaspis-cana-_Mole_Snake_Tyrone_Ping_2018-13.jpg
221	\N	\N	./animals/nm_lp13k2mmuT4xvc9izBu1onej1QJa5TGZNUIo8Ygg.jpg
222	508	700	./animals/90060030.jpg
223	768	1024	./animals/2521114862_ed7667f0cf_b.jpg
224	689	1024	./animals/12800710134_6bc857fb8b_b.jpg
225	738	1024	./animals/6257372409_e7e3f67c31_b.jpg
226	1111	1800	./animals/star-nosed-mole.jpg
227	414	537	./animals/condylura-cristata.jpg
228	\N	\N	./animals/v7idvzx4kz621.jpg
229	682	1023	./animals/5492895013_4886594084_b.jpg
230	666	1000	./animals/I0000soUmUv93s4s.jpg
231	533	710	./animals/Gecarcoidea_natalis.jpg
232	1024	1024	./animals/Macaca%2Bfascicularis.jpg
233	1690	1067	./animals/macaca-fascicularis-portrait-close-up-31017241.jpg
234	367	550	./animals/flat,550x550,075,f.jpg
235	600	900	./animals/crabeater-seal-lobodon-carcinophaga-steven-j-kazlowski--ghg.jpg
236	600	900	./animals/crabeater-seal-lobodon-carcinophaga-nick-dale.jpg
237	820	1232	./animals/portrait-of-crabeater-seal-lobodon-carcinophaga-sleeping-on-ice-RUNF03656.jpg
238	119	150	./animals/40636_cancer-borealis.jpg
239	119	150	./animals/40636_cancer-borealis.jpg
240	866	1300	./animals/species_8e_5a018cadb6f1f.w1300.h866.jpg
241	600	1030	./animals/Kingcrab1-1030x600.jpg
242	701	1050	./animals/lopholithodes-mandtii-puget-sound-king-crab-amid-plumose-anemones-photo-34348-7392.jpg
243	384	512	./animals/KingCrab2.512.jpg
244	768	1024	./animals/Cancer_productus1DLC2005.jpg
245	318	318	./animals/ggJxMlm1_400x400.jpg
246	666	1000	./animals/species_54_59db34f0a742b.w1000.h666.jpg
247	753	1002	./animals/Snow+Crab.jpg
248	1260	2520	./animals/2520x1260px_snowcrab_species.jpg
249	752	1011	./animals/C+tanneri+with+BCD+%2528top%2529.jpg
250	1360	1600	./animals/Eastern+Bluebird+(Sialia+sialis)Hal+Scott+Preserve+Florida+2.jpg
252	1201	1474	./animals/Eastern+Bluebird+(Sialia+sialis)Hal+Scott+Preserve+Florida+1.jpg
255	1415	1597	./animals/Eastern+bluebird+Sialia+sialis.jpg
256	900	600	./animals/fregata-wielka.jpg
257	\N	\N	./animals/Fregata-3.jpg
262	960	1200	./animals/fregata-1.jpg
265	1776	2500	./animals/99A5370_Mountain-Bluebird-output.jpg
266	1749	2500	./animals/99A5345_Mountain-bluebird-female-output.jpg
267	1078	1600	./animals/mountain_bluebird_sialia_currucoides_P7030240.jpg
268	1776	2500	./animals/99A5370_Mountain-Bluebird-output.jpg
269	1749	2500	./animals/99A5345_Mountain-bluebird-female-output.jpg
270	1078	1600	./animals/mountain_bluebird_sialia_currucoides_P7030240.jpg
271	800	640	./animals/siacur11.jpg
272	1049	1469	./animals/5mobl.jpg
273	1200	1600	./animals/mountain_bluebird_sialia_currucoides_P7030241.jpg
277	534	800	./animals/travailleur.a.bec.rouge.frpe.2g.jpg
278	884	1178	./animals/Quelea,_Red-billed_Bernard_Dupont.jpg
280	723	1024	./animals/Red-winged-Blackbird-Agelaius-phoeniceus-New-Jersey-1024x723.jpg
281	1300	1159	./animals/6805-Red-winged-Blackbird-Agelaius-phoeniceus-Hagerman-NWR-Texas.jpg
282	1300	1020	./animals/6806-Red-winged-Blackbird-Agelaius-phoeniceus-Hagerman-NWR-Texas.jpg
283	723	1024	./animals/Red-winged-Blackbird-Agelaius-phoeniceus-New-Jersey-1024x723.jpg
284	1300	1159	./animals/6805-Red-winged-Blackbird-Agelaius-phoeniceus-Hagerman-NWR-Texas.jpg
285	1300	1020	./animals/6806-Red-winged-Blackbird-Agelaius-phoeniceus-Hagerman-NWR-Texas.jpg
287	545	612	./animals/Red-billed+quelea+Quelea+quelea.jpg
288	522	736	./animals/fab86a694777b3368e0206762a998e92--s-organizations.jpg
289	175	220	./animals/220px-Agelaius_phoeniceus_0110_taxo.jpg
290	955	1300	./animals/an-immature-red-winged-blackbird-agelaius-phoeniceus-male-perched-on-a-spruce-tree-branch-in-rural-alberta-canada-2BTP6M6.jpg
291	175	220	./animals/220px-Agelaius_phoeniceus_0110_taxo.jpg
292	498	640	./animals/ruby_throated_hummingbird.jpg
293	414	537	./animals/archilochus-colubris.jpg
294	1208	1563	./animals/Archilochus-colubris-esta-tres_2988.jpg
303	1200	1600	./animals/cephalopterus-ornatus.jpg
304	1024	685	./animals/49923863051_5f2321aa22_b.jpg
308	1066	1600	./animals/Guarda-chuva-de-pescoço-pelado%2B(Cephalopterus%2Bglabricollis)%2B14%2B-%2BGould%2C%2B1851%2B EN .jpg
309	399	260	./animals/773163673.jpg
310	564	573	./animals/Selenarctos-tibetanus.jpg
311	1226	1160	./animals/ABBear+cub.jpg
312	2048	1544	./animals/2dc57ed424cbd2098034d546d2dca217.jpg
313	1060	1600	./animals/pogona_vitticeps_by_nakkimo-datfsnt.jpg
314	488	560	./animals/Pogona-vitticeps-03000013144_01.jpg
315	576	768	./animals/Pogona_vitticeps-768x576.jpg
316	2404	3607	./animals/Ursus_americanus_3303.jpg
317	800	1200	./animals/oso-negro-1.jpg
318	959	1200	./animals/33d64c45bad3a1c7bd4a5e3c78556439.jpg
319	1080	1920	./animals/UrsusMaritimus.jpg
320	600	800	./animals/f6ce065c-c7e0-40a9-8369-e80ac97e738d.jpg
321	200	200	./animals/ursus-maritimus-polar-bear-zoo-bear-mammal-fauna-terrestrial-animal-snout-arctic-carnivoran-wildlife-fur-1430599.jpg
322	1067	1600	./animals/MU336-01-01.jpg
323	1000	1500	./animals/pichincha--reserva-maquipucuna_ac.jpg
324	597	900	./animals/spectacled-bear-tremarctos-ornatus-cub-pete-oxford.jpg
325	400	600	./animals/sun-bear-75873.jpg
326	1161	1600	./animals/sun-bear-helarctos-malayanus-9472363.jpg
327	997	1500	./animals/malayan-sun-bear-helarctos-malayanus-w-1500.jpg
328	433	650	./animals/Peromyscus-from-fotonatura.org_.jpg
329	630	1200	./animals/Peromyscus%2Bmaniculatus.jpg
330	369	1200	./animals/deer_mouse_maniculatus_for_web_001.jpg
331	678	1024	./animals/8540321998_086a2dcc47_b.jpg
332	570	726	./animals/mmu-juv-lge-0213.jpg
333	398	600	./animals/Gray_Mouse_Lemur_-_Microcebus_Murinus_600.jpg
334	1197	1795	./animals/Struthio_camelus_-_Etosha_2014_(3).jpg
335	920	1380	./animals/massai_strauss.jpg
336	669	1000	./animals/221596.jpg
337	1948	2715	./animals/Loxodonta_africana_2007-01-02_04.jpg
338	1486	2259	./animals/Loxodonta_africana_2007-01-02_05.jpg
339	600	900	./animals/african-elephant-loxodonta-africana-danita-delimont.jpg
340	680	1023	./animals/8568335701_29c86485df_b.jpg
341	534	800	./animals/african-forest-elephant-loxodonta-cyclotis-16599081.jpg
342	500	500	./animals/Loxodonta-cyclotis.jpg
343	678	1024	./animals/7825284102_41d467d9f5_b.jpg
344	1072	1600	./animals/189848.jpg
345	1600	1067	./animals/Asian_elephant_-_melbourne_zoo.jpg
346	682	1023	./animals/49022972158_e67b8444aa_b.jpg
347	333	500	./animals/49023493256_2793717585.jpg
348	534	800	./animals/borneo-pygmy-elephants-elephas-maximus-borneensis-borneo-malaysia-asia-borneo-pygmy-elephants-elephas-maximus-borneensis-151954477.jpg
349	850	565	./animals/northern-elephant-seal-mirounga-angustirostris-photograph-15491-174408.jpg
350	2505	3131	./animals/Mating_scene_with_elevated_Alpha_Male._Elephant_Seals_of_Piedras_Blancas.jpg
351	344	500	./animals/Mirounga angustirostrisPh2.jpg
352	448	700	./animals/bb63a4ba-361f-4241-9c51-dd2d01e81535.jpg
353	956	1300	./animals/bushveld-elephant-shrew-elephantulus-intufi-nossob-riverbed-botswana-D8C60P.jpg
354	999	1505	./animals/1d657b742ed7e61c71a6808926b2d53a.jpg
355	768	1024	./animals/5888284491_6d106ea410_b.jpg
356	2618	3648	./animals/1490254212.jpg
357	1157	1600	./animals/indian-elephant-elephas-maximus-indicus-107875820.jpg
358	1732	2598	./animals/Elephas_maximus_(Bandipur).jpg
359	920	800	./animals/elephas_maximus_maximus_by_sinammonite-d5bbqq7.jpg
360	599	900	./animals/asian-elephant-elephas-maximus-male-david-courtenay.jpg
361	534	800	./animals/sumatran-elephant-elephas-maximus-sumatranus-ragunan-wildlife-park-ragunan-zoo-sumatran-elephant-elephas-maximus-260642083.jpg
362	390	588	./animals/Zagrozone_ssaki_9.jpg
363	427	640	./animals/32243007121.jpg
364	439	750	./animals/DicerosBicornis.jpg
365	2389	3655	./animals/Black_Rhino_Diceros_bicornis.jpg
366	655	1000	./animals/fotos-del-diceros-bicornis-longipes.jpg
367	720	1200	./animals/panzernashorn-rhinoceros-unicornis-bulle-zoo-16485.jpg
368	600	800	./animals/Rhinoceros_unicornis_-Higashiyama_Zoo-8.jpg
369	900	1200	./animals/panzernashorn-rhinoceros-unicornis-bulle-tierpark-16090.jpg
370	447	794	./animals/badak-jawa-taman-nasional-ujung-kulon-bc197ca27ddcfe491e011f0a726d5f5b.jpg
371	768	1024	./animals/rhinoceros_sondaicus.jpg
372	768	1024	./animals/rhinoceros-8775.jpg
373	1118	1680	./animals/if.jpg
374	294	588	./animals/Nosorozec_sumatrzanski-588x294.jpg
375	480	754	./animals/sumatran-rhinoceros.jpg
376	683	1024	./animals/8503485139_0b55e2a857_b.jpg
377	920	1380	./animals/breitmaulnashorn.jpg
378	707	1024	./animals/37039630706_a0b318d379_b.jpg
379	1371	1761	./animals/1163553160.jpg
380	800	1000	./animals/d08a470e27d9694eb46d0e37553c4984.jpg
381	714	500	./animals/tumblr_ls56wzYPHf1qa9omho1_500.jpg
382	683	1024	./animals/47014375374_b8d5db0e6a_b.jpg
384	1954	2613	./animals/Panthera_p_pardus_2007-01-02_12.jpg
385	2500	1857	./animals/Panthera_pardus_close_up.jpg
386	3169	4762	./animals/African_leopard%2C_Panthera_pardus_pardus%2C_near_Lake_Panic%2C_Kruger_National_Park%2C_South_Africa_(19448654130).jpg
387	423	636	./animals/blwonkmtc2ogl6lakros.jpg
388	451	660	./animals/1048.jpg
389	316	474	./animals/Proteles_cristata_01_480x320.jpg
390	719	926	./animals/71331296_large.jpg
391	600	800	./animals/arctic_wolf1.jpg
392	1024	683	./animals/7486343504_e7b5f5bc27_b.jpg
393	896	1200	./animals/1200px-Latrodectus_hesperus_Berkeley%2C_California.jpg
394	533	800	./animals/IH372-latrodectus-mactans.jpg
395	963	1024	./animals/2984154394_52ec7b12e7_b.jpg
396	719	960	./animals/domestic-horse-1502652_960_720.jpg
397	672	900	./animals/equus_ferus_caballus_by_kaitengiri.jpg
398	823	545	./animals/Cavalos%2B%252813%2529.jpg
399	1600	1163	./animals/leopard.jpg
400	875	1500	./animals/neofelis-nebulosa-w-1500.jpg
401	900	1600	./animals/19584qii9wu0rjpg.jpg
402	595	600	./animals/Parasteatoda_tepidariorum_w_7mm.jpg
403	1028	800	./animals/parasteatoda-tepidariorum-22.jpg
404	588	640	./animals/the_ach_tep_a1.jpg
405	800	1066	./animals/9891265_orig.jpg
406	900	606	./animals/coopers-hawk-accipiter-cooperii-richard-and-susan-day.jpg
407	600	800	./animals/aP1200426.jpg
408	\N	\N	./animals/European-grey-wolf--014.jpg
410	1080	1920	./animals/CanisLupus.jpg
411	563	1000	./animals/ocypus-olens-3--1.jpg
412	563	1000	./animals/ocypus-olens-4--1.jpg
413	800	800	./animals/ocypus-olens-x2-x5.jpg
414	1200	1800	./animals/Dysdere-Armee.jpg
415	580	562	./animals/Dysdera-crocata-with-big-jaws.jpg
416	850	1082	./animals/dysdera-crocata-9.jpg
417	733	1100	./animals/shutterstock-1111168676.jpg
418	956	1300	./animals/the-spider-tailed-horned-viper-pseudocerastes-urarachnoides-is-a-species-of-viper-endemic-to-western-iran-which-was-only-described-in-2006-the-spid-P1MNBD.jpg
419	956	1300	./animals/arana-tailed-vibora-cornuda-pseudocerastes-urarachnoides-los-montes-zagros-provincia-de-ilam-iran-h8wt90.jpg
420	900	598	./animals/spider-monkey-simia-paniscus-on-a-tree-panoramic-images.jpg
421	957	1300	./animals/spider-monkey-simia-paniscus-2JRY367.jpg
422	1500	1185	./animals/21012817041.jpg
423	1000	1000	./animals/python-regius-bamboo-python-royal.jpg
424	768	1024	./animals/03000018316_01_f.jpg
425	1000	1000	./animals/python-regius-black-pastel-python-royal.jpg
426	683	1024	./animals/Latrodectus-Hasselti-Best-Wallpaper-1024x683.jpg
428	533	800	./animals/Latrodectus_hasselti_D2750_Z_84_-_Australie.jpg
429	1600	1200	./animals/1200px-Nephila-clavata-f-eating-and-2-m.jpg
430	\N	\N	./animals/j5snmna4c1t71.jpg
431	559	560	./animals/1KMKDKXKUKUQT0GQC0EQC05QT0EQ9KSK6K5Q2KHKBK9QHSUQDK4KJ0WQDKMK30UQVK9QHS8K1KIKJ07KOK5KJ0NQHSNQ.jpg
432	1000	750	./animals/DSCN1718.jpg
433	2936	4289	./animals/Steatoda_grossa_Cupboard_Spider.jpg
434	1441	1457	./animals/5c10febb4b-arana03dec.jpg
435	800	1200	./animals/Oryctolagus-cuniculus.jpg
436	768	1024	./animals/3897187267_f36b5e4e7a_b.jpg
437	1709	1367	./animals/Oryctolagus-cuniculus-Tasmania-2.jpg
438	851	1280	./animals/Iepurele-de-California-Lepus-californicus-are-urechile-uriașe.jpg
439	1690	1422	./animals/black-tailed-jackrabbit-beautiful-lepus-californicus-american-desert-hare-sits-sand-borrego-springs-california-150855630.jpg
440	900	600	./animals/lepus-californicus-kathleen-bishop.jpg
441	953	1400	./animals/Falco_peregrinus_-_01-wikimedia-e1502419650980.jpg
442	1599	2400	./animals/2147567_l.jpg
443	\N	\N	./animals/peregr2.jpg
444	231	295	./animals/sea-cow2.jpg
445	349	700	./animals/dd7dd4117055440e685c301381e63028.jpg
446	465	757	./animals/b8ad9378dd3b7a768c3eaeddda5a22cf.jpg
447	2507	3291	./animals/Leopard_seal_(Hydrurga_leptonyx).jpg
448	956	1300	./animals/adult-leopard-seal-hydrurga-leptonyx-booth-island-antarctica-southern-DBPAA6.jpg
449	798	1200	./animals/Amos-Nachoun.jpg
450	768	1024	./animals/eublepharis-macularius.jpg
451	540	720	./animals/md423c7h.jpg
452	430	750	./animals/18637.jpg
453	3994	5991	./animals/d22c4554fc692381eff3ddd9a0b0d00c.jpg
454	650	650	./animals/Trioceros-jacksonii.jpg
455	2016	3024	./animals/d8e6a452d1592ad1476b5a01574038a1.jpg
456	1865	2337	./animals/6dscn8910.jpg
457	579	1024	./animals/Horse-Equus-ferus-caballus-1.jpg
458	2009	2577	./animals/2dscn3393.jpg
462	1196	1800	./animals/equus-caballus001.jpg
463	599	900	./animals/1-domestic-horse-equus-caballus-pair-konrad-wothe.jpg
464	800	533	./animals/equus-caballus-104863.jpg
465	1001	1500	./animals/lycodon-capucinus-w-1500.jpg
466	600	900	./animals/lycodon-capucinus-w-900.jpg
467	600	900	./animals/lycodon-capucinus-dixonius-pawangkhananti-w-900.jpg
468	866	1300	./animals/species_ac_59d585bf5b7fd.w1300.h866.jpg
469	1331	2000	./animals/FIS030-00082.jpg
470	618	1100	./animals/1327150_orig.jpg
471	832	1000	./animals/Red-Wolf-Animals-Captive.jpg
472	1281	1600	./animals/grey-wolf.jpg
473	818	1024	./animals/red+wolf.jpg
474	1330	1995	./animals/776026_12c811a61cd8477981d29f66276904f4~mv2.jpg
475	1323	1920	./animals/df43cb26220317.56353355a79a4.jpg
476	1228	1400	./animals/d87bda26220317.5635333fb0441.jpg
477	2047	1900	./animals/Canis_lupus_occidentalis.jpg
478	300	500	./animals/canis-lupus-occidentalis-facts.jpg
479	369	550	./animals/canis-lupus-occidentalis-wow.jpg
480	2004	3000	./animals/Canis_lupus_laying_in_grass.jpg
481	200	200	./animals/353-Canis-Lupus-Signatus-1.jpg
482	1600	2400	./animals/1746119_large65835.jpg
483	900	720	./animals/canis-lupus-signatus-fegari.jpg
484	2180	2500	./animals/Head+shot+100-400.jpg
485	901	1200	./animals/europaeischer-wolf-canis-lupus-lupus-16425.jpg
486	1600	1466	./animals/Pepsis%2Bthisbe%2BMale3%2BCuy%2BWds%2BJulian%2BCA%2BOct%2B17%2B2015.jpg
487	455	560	./animals/L0I0Z0E0Q020ORXQH07QARFK3QU0L0SQ3RW0R0X0DQ50OQ70BRZQYQW0FR7QH0IQFRHQJQ403QYK.jpg
488	1080	1080	./animals/7adba93d37d22cd9eabbb89113e8cad5.jpg
489	1024	1122	./animals/Accipiter-nisus-II-Wikimedia-Commons.jpg
490	800	600	./animals/accipiter_nisus_saj.jpg
491	469	510	./animals/AccipiterNisus1.jpg
492	1365	2047	./animals/Parabuteo_unicinctus-05.jpg
493	1600	2400	./animals/2384336_large20449.jpg
494	1133	1700	./animals/2c109cfa4fe8905359dfab2b9a305780.jpg
495	800	1200	./animals/Accipiter_gentilis_by_Iosto_Doneddu.jpg
496	531	800	./animals/Accipiter-gentilis-laingi.jpg
497	600	400	./animals/accipiter-gentilis-7_313.jpg
498	477	499	./animals/32356223035_0152794290.jpg
499	900	900	./animals/buteo-regalis-gabriela-insuratelu.jpg
500	667	1000	./animals/2012_119_buteo_regalis_by_w0lle-d5koh0o.jpg
503	599	900	./animals/canis_lupus_by_picturebypali-d3bz4iq.jpg
504	797	1200	./animals/Latrodectus-Hasselti-Photo-Download.jpg
505	1600	1600	./animals/earth.jpg
506	2592	3888	./animals/antarctica.jpg
507	4000	6000	./animals/234720-sea-water-underwater-waves-split_view-rainbows.jpg
508	1100	1015	./animals/asia_b.jpg
509	3000	2180	./animals/il_fullxfull.1367302856_n1be.jpg
510	1430	1190	./animals/full_political_map_of_south_america.jpg
511	5400	6773	./animals/large_detailed_political_map_of_Eurasia_wth_capitals_and_major_cities_2006.jpg
512	1600	1243	./animals/north_america_map.jpg
513	1164	1097	./animals/Map-of-Africa.jpg
514	657	855	./animals/central_america_map_file.jpg
515	723	1280	./animals/69156_61004a32c2681.jpg
516	912	1100	./animals/hippocampus.jpg
517	1023	1500	./animals/hippocampus_brain-5783df885f9b5831b5cee889.jpg
518	780	900	./animals/hippocampus-in-the-brain-roger-harris.jpg
519	316	535	./animals/medium.jpg
520	1155	1600	./animals/capybara-hydrochoerus-hydrochaeris-native-to-south-america-largest-rodent-world-94567169.jpg
521	1157	1600	./animals/capybara-hydrochoerus-hydrochaeris-very-cute-largest-rodent-133870990.jpg
522	532	800	./animals/canadian-river-otter-lutra-canadensis-1016246.jpg
523	500	500	./animals/lutra_canadensis_ad9403.jpg
524	956	1300	./animals/la-loutre-de-riviere-s-lutra-canadensis-wyoming-loutre-de-riviere-s-lutra-canadensis-wyoming-manger-des-oeufs-de-truite-fardee-bptgf5.jpg
525	1080	1920	./animals/LontraCanadensis-1.jpg
526	1650	2476	./animals/Lontra_canadensis_3274_fish.jpg
527	728	1100	./animals/4290575_orig.jpg
528	1280	1920	./animals/sea-otter-3194446_1920.jpg
529	1080	1620	./animals/Sea_Otters_Enhydra_lutris_the_Morro_Bay_harbor.jpg
530	768	1024	./animals/24.jpg
531	2840	3160	./animals/Ursus_maritimus_4_1996-08-04.jpg
532	1787	3200	./animals/1496742605.jpg
533	675	900	./animals/Platypus.jpg
534	682	1024	./animals/16453070535_def26603d2_b.jpg
535	931	1400	./animals/INS-1463.jpg
536	1600	2400	./animals/2843984_l.jpg
537	797	1200	./animals/533331.jpg
538	1199	1800	./animals/apatura-iris001.jpg
539	667	1000	./animals/_DSC5526.jpg
540	600	800	./animals/purple-emperor-butterfly-apatura-iris-der-grosse-schillerfalter-schmetterling-ili-velika-modra-preljevica-purple-emperor-butterfly-158713068.jpg
541	532	800	./animals/lepido1584209312.jpg
542	768	1024	./animals/39467.jpg
543	1199	1800	./animals/aglais-io001.jpg
544	1076	1024	./animals/danaus-plexippus-gustavo-blanco-vale_orig.jpg
545	2000	2800	./animals/Monarch_Butterfly_Danaus_plexippus_on_Echinacea_purpurea_2800px.jpg
546	469	780	./animals/KF-Monarch.jpg
547	755	1024	./animals/2964411147_27d1409f4a_b.jpg
548	1066	1600	./animals/Antílope-saiga+(Saiga+tatarica)+12+-+Linnaeus,+1766.jpg
549	1066	1600	./animals/Antílope-saiga+(Saiga+tatarica)+9+-+Linnaeus,+1766.jpg
550	1390	866	./animals/goat-capra-aegagrus-hircus-F0T2TC.jpg
551	956	1300	./animals/goat-capra-aegagrus-hircus-D6FT44.jpg
552	532	800	./animals/capra-aegagrus-hircus-26293841.jpg
553	662	588	./animals/Serval-4.jpg
554	1536	1152	./animals/Leptailurus-serval-1152x1536.jpg
555	1934	2907	./animals/iStock-614951366-1619793513510.jpg
556	563	1000	./animals/narwhal-6.jpg
557	1000	1500	./animals/Нарвал_в_российской_Арктике.jpg
558	768	1124	./animals/Monodon-monoceros.jpg
559	1023	682	./animals/depositphotos_126490400-stock-photo-okapi-okapia-johnstoni.jpg
560	1024	680	./animals/26258852-okapi-okapia-johnstoni.jpg
561	657	750	./animals/213609.jpg
562	1864	2913	./animals/Canis_lupus_arctos_(Pocock%2C_1935).jpg
563	992	990	./animals/hippocampus-brain-gty-rc-180927_hpEmbed_1x1_992.jpg
564	1832	5184	./animals/Hippocampus-cropped.jpg
565	675	1200	./animals/EABXjyXx2sTXX4parbADzS-1200-80.jpg
566	132	641	./animals/near-threatened.jpg
567	1071	1500	./animals/Flamingo5.jpg
568	1050	1400	./animals/Flamingo-flamingos-35634890-1400-1050.jpg
569	1200	1600	./animals/flamingo-pictures.jpg
\.


--
-- Data for Name: location; Type: TABLE DATA; Schema: public; Owner: dbuser
--

COPY public.location (id, name, slug) FROM stdin;
17	Central-America	central-america
18	North-America	north-america
19	Africa	africa
20	Eurasia	eurasia
21	Ocean	ocean
22	South-America	south-america
23	Asia	asia
24	Europe	europe
25	Oceania	oceania
27	Antarctica	antarctica
28	Earth	earth
\.


--
-- Data for Name: location_images; Type: TABLE DATA; Schema: public; Owner: dbuser
--

COPY public.location_images (id, location_id, image_id) FROM stdin;
1	27	506
2	28	505
4	25	507
5	23	508
6	24	509
7	22	510
8	21	507
9	20	511
10	18	512
11	19	513
12	17	514
\.


--
-- Data for Name: page; Type: TABLE DATA; Schema: public; Owner: dbuser
--

COPY public.page (id, slug, title, content, image_id) FROM stdin;
2	search	Search		121
3	taxonomy	Taxonomy		121
4	hierarchy	Hierarchy		121
1	home	Homepage	<p>I is not fat, i is fluffy my cat stared at me he was sipping his tea, too so when in doubt, wash. Stare at the wall, play with food and get confused by dust give attitude, yet lick butt and make a weird face but cough. Nap all day you have cat to be kitten me right meow flee in terror at cucumber discovered on floor favor packaging over toy rub face on everything, or kitty poochy. Making sure that fluff gets into the owner's eyes fish i must find my red catnip fishy fish cough hairball on conveniently placed pants where is it? i saw that bird i need to bring it home to mommy squirrel! mouse chase little red dot someday it will be mine! for fight own tail. I love cats i am one wake up scratch humans leg for food then purr then i have a and relax meeeeouw. Hide at bottom of staircase to trip human scratch me there, elevator butt but cuddle no cuddle cuddle love scratch scratch, and cough furball. Scratch me there, elevator butt funny little cat chirrup noise shaking upright tail when standing next to you stare out the window ears back wide eyed. Cat slap dog in face. The fat cat sat on the mat bat away with paws annoy the old grumpy cat, start a fight and then retreat to wash when i lose commence midnight zoomies spend six hours per day washing, but still have a crusty butthole so use lap as chair scratch me now! stop scratching me!. Purr when being pet meowing non stop for food. Refuse to drink water except out of someone's glass nyan fluffness ahh cucumber! or trip owner up in kitchen i want food so chase ball of string. Reward the chosen human with a slow blink eat too much then proceed to regurgitate all over living room carpet while humans eat dinner but love fish cat walks in keyboard massacre a bird in the living room and then look like the cutest and most innocent animal on the planet and get my claw stuck in the dog's ear meow meow. Run around the house at 4 in the morning run off table persian cat jump eat fish and leave hair on owner's clothes but chirp at birds stare at imaginary bug. Run in circles good now the other hand, too so spend six hours per day washing, but still have a crusty butthole, woops poop hanging from butt must get rid run run around house drag poop on floor maybe it comes off woops left brown marks on floor human slave clean lick butt now so intently stare at the same spot kitten is playing with dead mouse. Kitty scratches couch bad kitty eat grass, throw it back up take a deep sniff of sock then walk around with mouth half open yet find box a little too small and curl up with fur hanging out cuddle no cuddle cuddle love scratch scratch the fat cat sat on the mat bat away with paws or playing with balls of wool. Proudly present butt to human meowing chowing and wowing and mewl for food at 4am but kitty time. Pretend not to be evil lick the other cats. Mesmerizing birds purr pet me pet me don't pet me ears back wide eyed so twitch tail in permanent irritation sniff sniff. Sleeping in the box walk on keyboard. Sleeps on my head favor packaging over toy munch on tasty moths, for love blinks and purr purr purr purr yawn allways wanting food for get scared by sudden appearance of cucumber. Put butt in owner's face cough. Slap the dog because cats rule attempt to leap between furniture but woefully miscalibrate and bellyflop onto the floor; what's your problem? i meant to do that now i shall wash myself intently. I could pee on this if i had the energy you have cat to be kitten me right meow for cat mojo . Hate dog lie in the sink all day one of these days i'm going to get that red dot, just you wait and see for soft kitty warm kitty little ball of furr, lick face hiss at owner, pee a lot, and meow repeatedly scratch at fence purrrrrr eat muffins and poutine until owner comes back for ccccccccccccaaaaaaaaaaaaaaatttttttttttttttttssssssssssssssss.\n</p>\n<p>\nWake up human for food at 4am claw your carpet in places everyone can see - why hide my amazing artistic clawing skills? but eat plants, meow, and throw up because i ate plants. I shall purr myself to sleep cat jumps and falls onto the couch purrs and wakes up in a new dimension filled with kitty litter meow meow yummy there is a bunch of cats hanging around eating catnip or decide to want nothing to do with my owner today adventure always but wake up human for food at 4am. Chew master's slippers refuse to leave cardboard box and claws in your leg kitty power stare at wall turn and meow stare at wall some more meow again continue staring . Don't nosh on the birds human is washing you why halp oh the horror flee scratch hiss bite. Eat an easter feather as if it were a bird then burp victoriously, but tender swat turds around the house pounce on unsuspecting person pelt around the house and up and down stairs chasing phantoms yet need to chase tail, so plays league of legends. Iâ€™m so hungry iâ€™m so hungry but ew not for that make meme, make cute face for morning beauty routine of licking self. Jump on counter removed by human jump on counter again removed by human meow before jumping on counter this time to let the human know am coming back the cat was chasing the mouse yet this cat happen now, it was too purr-fect!!!.\n</p>\n<p>\nCatasstrophe scratch the postman wake up lick paw wake up owner meow meow yet mouse my left donut is missing, as is my right you call this cat food. Take a big fluffing crap ðŸ’© purr so lick master's hand at first then bite because im moody do not try to mix old food with new one to fool me! or pet me pet me pet me pet me, bite, scratch, why are you petting me. Wake up human for food at 4am blow up sofa in 3 seconds so stand in front of the computer screen at four in the morning wake up owner meeeeeeooww scratch at legs and beg for food then cry and yowl until they wake up at two pm jump on window and sleep while observing the bootyful cat next door that u really like but who already has a boyfriend end up making babies with her and let her move in but purrr purr littel cat, little cat purr purr. Leave dead animals as gifts cough hairball on conveniently placed pants, ha ha, you're funny i'll kill you last, for jumps off balcony gives owner dead mouse at present then poops in litter box snatches yarn and fights with dog cat chases laser then plays in grass finds tiny spot in cupboard and sleeps all day jumps in bathtub and meows when owner fills food dish the cat knocks over the food dish cat slides down the water slide and into pool and swims even though it does not like water be superior for claws in the eye of the beholder. You call this cat food humans,humans, humans oh how much they love us felines we are the center of attention they feed, they clean but bite the neighbor's bratty kid and climb into cupboard and lick the salt off rice cakes so going to catch the red dot today going to catch the red dot today. If it fits, i sits sniff all the things sleep over your phone and make cute snoring noises for poop on the floor, break a planter, sprint, eat own hair, vomit hair, hiss, chirp at birds, eat a squirrel, hide from fireworks, lick toe beans, attack christmas tree. Leave dead animals as gifts chase little red dot someday it will be mine! flop over leave hair everywhere. Stretch pee in human's bed until he cleans the litter box tickle my belly at your own peril i will pester for food when you're in the kitchen even if it's salad , push your water glass on the floor for touch my tail, i shred your hand purrrr, funny little cat chirrup noise shaking upright tail when standing next to you and eat a rug and furry furry hairs everywhere oh no human coming lie on counter don't get off counter. Ha ha, you're funny i'll kill you last thinking about you i'm joking it's food always food cough the dog smells bad. Always hungry catty ipsum toy mouse squeak roll over cuddle no cuddle cuddle love scratch scratch attack like a vicious monster. Go crazy with excitement when plates are clanked together signalling the arrival of cat food give attitude eat all the power cords for eat the fat cats food take a big fluffing crap ðŸ’©. Eat grass, throw it back up why must they do that mewl for food at 4am. Hate dog fall asleep upside-down give me attention or face the wrath of my claws, pet me pet me pet me pet me, bite, scratch, why are you petting me and waffles so scream for no reason at 4 am prow?? ew dog you drink from the toilet, yum yum warm milk hotter pls, ouch too hot. Drool find box a little too small and curl up with fur hanging out chase red laser dot touch water with paw then recoil in horror. Time to go zooooom cats making all the muffins.\n</p>	121
5	about	About	Something about	121
7	contact	Contact	contact info	121
\.


--
-- Data for Name: taxonomy; Type: TABLE DATA; Schema: public; Owner: dbuser
--

COPY public.taxonomy (id, category_id, name, parent_id, slug) FROM stdin;
1	1	Animalia	0	animalia
2	2	Hemichordata	1	hemichordata
3	3	Aves	2	aves
4	4	Accipitriformes	3	accipitriformes
5	5	Accipitridae	4	accipitridae
6	6	Accipiter	5	accipiter
7	2	Chordata	1	chordata
8	6	Buteo	5	buteo
9	6	Parabuteo	5	parabuteo
10	2	Arthropoda	1	arthropoda
11	3	Insecta	10	insecta
12	4	Hymenoptera	11	hymenoptera
13	5	Pompilidae	12	pompilidae
14	6	Pepsis	13	pepsis
15	3	Mammalia	7	mammalia
16	4	Rodentia	15	rodentia
17	5	Cricetidae	16	cricetidae
18	6	Peromyscus	17	peromyscus
19	4	Primates	15	primates
20	5	Cheirogaleidae	19	cheirogaleidae
21	6	Microcebus	20	microcebus
22	4	Lagomorpha	15	lagomorpha
23	5	Leporidae	22	leporidae
24	6	Lepus	23	lepus
25	4	Carnivora	15	carnivora
26	5	Hyaenidae	25	hyaenidae
27	6	Proteles	26	proteles
28	5	Canidae	25	canidae
29	6	Canis	28	canis
30	6	Chrysocyon	28	chrysocyon
31	3	Actinopterygii	7	actinopterygii
32	4	Perciformes	31	perciformes
33	5	Anarhichadidae	32	anarhichadidae
34	6	Anarrhichthys	33	anarrhichthys
35	3	Reptilia	7	reptilia
36	4	Squamata	35	squamata
37	5	Colubridae	36	colubridae
38	6	Lycodon	37	lycodon
39	4	Perissodactyla	15	perissodactyla
40	5	Equidae	39	equidae
41	6	Equus	40	equus
42	4	Coleoptera	11	coleoptera
43	5	Staphylinidae	42	staphylinidae
44	6	Ocypus	43	ocypus
45	4	Syngnathiformes	31	syngnathiformes
46	5	Syngnathidae	45	syngnathidae
47	6	Hippocampus	46	hippocampus
48	3	Chondrichthyes	7	chondrichthyes
49	4	Lamniformes	48	lamniformes
50	5	Cetorhinidae	49	cetorhinidae
51	6	Cetorhinus	50	cetorhinus
52	4	Carcharhiniformes	48	carcharhiniformes
53	5	Carcharhinidae	52	carcharhinidae
54	6	Prionace	53	prionace
55	5	Sphyrnidae	52	sphyrnidae
56	6	Sphyrna	55	sphyrna
57	6	Carcharhinus	53	carcharhinus
58	4	Hexanchiformes	48	hexanchiformes
59	5	Chlamydoselachidae	58	chlamydoselachidae
60	6	Chlamydoselachus	59	chlamydoselachus
61	5	Mitsukurinidae	49	mitsukurinidae
62	6	Mitsukurina	61	mitsukurina
63	5	Lamnidae	49	lamnidae
64	6	Carcharodon	63	carcharodon
65	4	Squaliformes	48	squaliformes
66	5	Somniosidae	65	somniosidae
67	6	Somniosus	66	somniosus
68	4	Heterodontiformes	48	heterodontiformes
69	5	Heterodontidae	68	heterodontidae
70	6	Heterodontus	69	heterodontus
71	5	Megachasmidae	49	megachasmidae
72	6	Megachasma	71	megachasma
73	4	Orectolobiformes	48	orectolobiformes
74	5	Ginglymostomatidae	73	ginglymostomatidae
75	6	Ginglymostoma	74	ginglymostoma
76	6	Lamna	63	lamna
77	6	Galeocerdo	53	galeocerdo
78	5	Etmopteridae	65	etmopteridae
79	6	Trigonognathus	78	trigonognathus
80	5	Rhincodontidae	73	rhincodontidae
81	6	Rhincodon	80	rhincodon
82	5	Stegostomatidae	73	stegostomatidae
83	6	Stegostoma	82	stegostoma
84	5	Felidae	25	felidae
85	6	Panthera	84	panthera
86	6	Neofelis	84	neofelis
87	5	Chamaeleonidae	36	chamaeleonidae
88	6	Trioceros	87	trioceros
89	6	Prionailurus	84	prionailurus
90	5	Eublepharidae	36	eublepharidae
91	6	Eublepharis	90	eublepharis
92	5	Phocidae	25	phocidae
93	6	Hydrurga	92	hydrurga
94	4	Testudines	35	testudines
95	5	Testudinidae	94	testudinidae
96	6	Stigmochelys	95	stigmochelys
97	4	Artiodactyla	15	artiodactyla
98	5	Bovidae	97	bovidae
99	6	Bos	98	bos
100	4	Sirenia	15	sirenia
101	5	Dugongidae	100	dugongidae
102	6	Hydrodamalis	101	hydrodamalis
103	4	Falconiformes	3	falconiformes
104	5	Falconidae	103	falconidae
105	6	Falco	104	falco
106	4	Passeriformes	3	passeriformes
107	5	Turdidae	106	turdidae
108	6	Sialia	107	sialia
109	4	Pelecaniformes	3	pelecaniformes
110	5	Fregatidae	109	fregatidae
111	6	Fregata	110	fregata
112	5	Ploceidae	106	ploceidae
113	6	Quelea	112	quelea
114	5	Icteridae	106	icteridae
115	6	Agelaius	114	agelaius
116	4	Apodiformes	3	apodiformes
117	5	Trochilidae	116	trochilidae
118	6	Archilochus	117	archilochus
119	5	Cotingidae	106	cotingidae
120	6	Cephalopterus	119	cephalopterus
121	6	Ploceus	112	ploceus
122	6	Oryctolagus	23	oryctolagus
123	3	Arachnida	10	arachnida
124	4	Araneae	123	araneae
125	5	Theridiidae	124	theridiidae
126	6	Latrodectus	125	latrodectus
128	6	Parasteatoda	125	parasteatoda
130	6	Steatoda	125	steatoda
131	5	Araneidae	124	araneidae
132	6	Trichonephila	131	trichonephila
133	5	Pythonidae	36	pythonidae
134	6	Python	133	python
135	5	Atelidae	19	atelidae
136	6	Ateles	135	ateles
137	5	Viperidae	36	viperidae
138	6	Pseudocerastes	137	pseudocerastes
139	5	Dysderidae	124	dysderidae
140	6	Dysdera	139	dysdera
141	6	Argiope	131	argiope
142	5	Ursidae	25	ursidae
143	6	Ursus	142	ursus
144	5	Agamidae	36	agamidae
145	6	Pogona	144	pogona
146	6	Ailuropoda	142	ailuropoda
147	6	Tremarctos	142	tremarctos
148	6	Helarctos	142	helarctos
149	6	Mesocricetus	17	mesocricetus
150	5	Bipedidae	36	bipedidae
151	6	Bipes	150	bipes
152	5	Pseudaspididae	36	pseudaspididae
153	6	Pseudaspis	152	pseudaspis
154	5	Heterocephalidae	16	heterocephalidae
155	6	Heterocephalus	154	heterocephalus
156	4	Eulipotyphla	15	eulipotyphla
157	5	Talpidae	156	talpidae
158	6	Condylura	157	condylura
159	3	Malacostraca	10	malacostraca
160	4	Decapoda	159	decapoda
161	5	Gecarcinidae	160	gecarcinidae
162	6	Gecarcoidea	161	gecarcoidea
163	5	Cercopithecidae	19	cercopithecidae
164	6	Macaca	163	macaca
165	5	Pinnipedia	25	pinnipedia
166	6	Lobodon	165	lobodon
167	5	Cancridae	160	cancridae
168	6	Cancer	167	cancer
169	5	Lithodidae	160	lithodidae
170	6	Lopholithodes	169	lopholithodes
171	5	Oregoniidae	160	oregoniidae
172	6	Chionoecetes	171	chionoecetes
173	4	Struthioniformes	3	struthioniformes
174	5	Struthionidae	173	struthionidae
175	6	Struthio	174	struthio
176	4	Proboscidea	15	proboscidea
177	5	Elephantidae	176	elephantidae
178	6	Loxodonta	177	loxodonta
179	6	Elephas	177	elephas
180	6	Mirounga	92	mirounga
181	4	Macroscelidea	15	macroscelidea
182	5	Macroscelididae	181	macroscelididae
183	6	Elephantulus	182	elephantulus
184	5	Rhinocerotidae	39	rhinocerotidae
185	6	Diceros	184	diceros
186	6	Rhinoceros	184	rhinoceros
187	6	Dicerorhinus	184	dicerorhinus
188	6	Ceratotherium	184	ceratotherium
189	5	Caviidae	16	caviidae
190	6	Hydrochoerus	189	hydrochoerus
191	5	Mustelidae	25	mustelidae
192	6	Lutra	191	lutra
193	5	Musteliodae	25	musteliodae
194	6	Lontra	193	lontra
195	6	Enhydra	191	enhydra
196	4	Monotremata	15	monotremata
197	5	Ornithorhynchidae	196	ornithorhynchidae
198	6	Ornithorhynchus	197	ornithorhynchus
199	4	Lepidoptera	11	lepidoptera
200	5	Nymphalidae	199	nymphalidae
201	6	Danaus	200	danaus
202	6	Aglais	200	aglais
203	6	Apatura	200	apatura
204	5	Pieridae	199	pieridae
205	6	Pieris	204	pieris
206	6	Saiga	98	saiga
207	6	Capra	98	capra
208	6	Leptailurus	84	leptailurus
209	4	Cetacea	15	cetacea
210	5	Monodontidae	209	monodontidae
211	6	Monodon	210	monodon
212	5	Giraffidae	97	giraffidae
213	6	Okapia	212	okapia
214	4	Diprotodontia	15	diprotodontia
215	5	Macropodidae	214	macropodidae
216	6	unknown	215	unknown
217	5	Heteromyidae	16	heteromyidae
218	6	Dipodomys	217	dipodomys
219	6	Dendrolagus	215	dendrolagus
220	4	Phoenicopteriformes	3	phoenicopteriformes
221	5	Phoenicopteridae	220	phoenicopteridae
222	6	Phoenicopterus	221	phoenicopterus
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: dbuser
--

COPY public.users (id, username, pass_hash) FROM stdin;
1	admin	$argon2id$v=19$m=19456,t=2,p=1$frvLavfnmBRqy7o0iVYxFg$UW/MbNbRXyJFE457E8ixyfhSHSRPpfW6o21xJqweTnY
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: dbuser
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
qNkTQuXBjlzm80spzzqDjg	\\x93c4108e833acf294bf3e65c8ec1e54213d9a881af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd01020a210bce055a92d7000000	2026-09-15 13:33:11.089821+03
HNxuBxaelXbDxzr4AuGysw	\\x93c410b3b2e102f83ac7c376959e16076edc1c81af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd01020c0523ce345d5d3d000000	2026-09-15 15:05:35.878533+03
HJzkJmlvBhW8wwPDZwqmlg	\\x93c41096a60a67c303c3bc15066f6926e49c1c81af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd01030b1731ce14544aa3000000	2026-09-16 14:23:49.341068+03
dzlvy9CkNlwFCtexpuEDKw	\\x93c4102b03e1a6b1d70a055c36a4d0cb6f397781af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd01050e092bce0e40339d000000	2026-09-18 17:09:43.239088+03
g7A6H2zTHSxEtJf_p4VYDw	\\x93c4100f5885a7ff97b4442c1dd36c1f3ab08381af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd010609362fce0902dbdf000000	2026-09-19 12:54:47.151182+03
qphtNbIGZ3iJeSpXYGuA7w	\\x93c410ef806b60572a7989786706b2356d98aa81af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd01080a162bce0db3b502000000	2026-09-21 13:22:43.229881+03
wqYH-kMXNXXbs-VgOcoIXA	\\x93c4105c08ca3960e5b3db75351743fa07a6c281af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd01090c2f07ce1a3de1ff000000	2026-09-22 15:47:07.440263+03
RJ3lDNSncVeuQoo74gB4QQ	\\x93c410417800e23b8a42ae5771a7d40ce59d4481af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd01190c052dce0b880967000000	2026-10-08 15:05:45.193464+03
Ok8dCrkxOgTHsGWPIG0zEw	\\x93c41013336d208f65b0c7043a31b90a1d4f3a81af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd011a090606ce2a0bf909000000	2026-10-09 12:06:06.705427+03
O-9SPBI39SKbLPccuCMCWA	\\x93c410580223b81cf72c9b22f537123c52ef3b81af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd011b081e20ce12d61725000000	2026-10-10 11:30:32.31602+03
2KP23oKAe5EhwGi3x3XEBQ	\\x93c41005c475c7b768c021917b8082def6a3d881af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd011b0d051bce3214afa0000000	2026-10-10 16:05:27.840216+03
8W78koyweMiwqmSm5ATBxw	\\x93c410c7c104e4a664aab0c878b08c92fc6ef181af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd011c092208ce388add49000000	2026-10-11 12:34:08.948624+03
XNGSuPg1Fqw1uf4ly4kUGg	\\x93c4101a1489cb25feb935ac1635f8b892d15c81af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd011d0d1610ce1566bb54000000	2026-10-12 16:22:16.359054+03
xgpJqktuG8F5o1es-MJCrg	\\x93c410ae42c2f8ac57a379c11b6e4baa490ac681af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd011e09172cce1b39b5cd000000	2026-10-13 12:23:44.456766+03
VEQRz93ZX9qh6kE2LFcQow	\\x93c410a310572c3641eaa1da5fd9ddcf11445481af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd0127092429ce104db8c6000000	2026-10-22 12:36:41.273529+03
hiGATkBC6TZtXMhQ8RGPeA	\\x93c410788f11f150c85c6d36e942404e80218681af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd0128092904ce345551df000000	2026-10-23 12:41:04.878006+03
LI6MGMfQi6MCQQuEXW3gYQ	\\x93c41061e06d5d840b4102a38bd0c7188c8e2c81af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd013a080411ce0f764317000000	2026-11-10 10:04:17.259408+02
b5HJ_Z46pN4JG3QsVtHkBQ	\\x93c41005e4d1562c741b09dea43a9efdc9916f81af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd013b0a1401ce355c754c000000	2026-11-11 12:20:01.895251+02
U90cflqXu1eUS6mKuKajEA	\\x93c41010a3a6b88aa94b9457bb975a7e1cdd5381af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd013c070a04ce0b879958000000	2026-11-12 09:10:04.193435+02
DWMF6rUQITuC_HCkNkkOHA	\\x93c4101c0e4936a470fc823b2110b5ea05630d81af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd013c0d272dce0e5cabe1000000	2026-11-12 15:39:45.240954+02
VtDSUa2atQrq0mrDVJppqg	\\x93c410aa699a54c36ad2ea0ab59aad51d2d05681af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd01420b3336ce003d05fe000000	2026-11-18 13:51:54.003999+02
rhgeH6g0n8FhtlNju4rOhQ	\\x93c41085ce8abb6353b661c19f34a81f1e18ae81af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd0144092327ce121ba8be000000	2026-11-20 11:35:39.303802+02
E06QEYhK88sqhLNzEMxwHg	\\x93c4101e70cc1073b3842acbf34a8811904e1381af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd01450e3416ce297a32bc000000	2026-11-21 16:52:22.695874+02
uqIyXgnqYSko5Lz7jSxnfw	\\x93c4107f672c8dfbbce4282961ea095e32a2ba81af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd01490f1923ce2bd69e5a000000	2026-11-25 17:25:35.735485+02
w1qy-5c4Cp44q5GUZYT9kA	\\x93c41090fd84659491ab389e0a3897fbb25ac381af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd014a0c083ace30a050f1000000	2026-11-26 14:08:58.815812+02
RwVD6y2SBU5IKDpnY84YpA	\\x93c410a418ce63673a28484e05922deb43054781af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd014a100f10ce2f71abd6000000	2026-11-26 18:15:16.795978+02
feVsVmehV1bR6Mq0-usHDg	\\x93c4100e07ebfab4cae8d15657a167566ce57d81af6178756d2d6c6f67696e2e6461746182a9617574685f68617368dc0061246172676f6e32696424763d3139246d3d31393435362c743d322c703d31246672764c6176666e6d42527179376f306956597846672455572f4d624e625258794a4645343537453869787966685348535250706657366f3231784a717765546e59a7757365725f6964a561646d696e99cd07eacd014c073704ce361e138c000000	2026-11-28 09:55:04.90794+02
\.


--
-- Name: animals_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dbuser
--

SELECT pg_catalog.setval('public.animals_category_id_seq', 1, false);


--
-- Name: animals_creature_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dbuser
--

SELECT pg_catalog.setval('public.animals_creature_id_seq', 1, false);


--
-- Name: animals_creature_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dbuser
--

SELECT pg_catalog.setval('public.animals_creature_images_id_seq', 1, false);


--
-- Name: animals_creature_locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dbuser
--

SELECT pg_catalog.setval('public.animals_creature_locations_id_seq', 1, false);


--
-- Name: animals_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dbuser
--

SELECT pg_catalog.setval('public.animals_image_id_seq', 1, false);


--
-- Name: animals_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dbuser
--

SELECT pg_catalog.setval('public.animals_location_id_seq', 1, false);


--
-- Name: animals_location_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dbuser
--

SELECT pg_catalog.setval('public.animals_location_images_id_seq', 1, false);


--
-- Name: animals_page_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dbuser
--

SELECT pg_catalog.setval('public.animals_page_id_seq', 7, true);


--
-- Name: animals_taxonomy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dbuser
--

SELECT pg_catalog.setval('public.animals_taxonomy_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dbuser
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: category animals_category_pkey; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT animals_category_pkey PRIMARY KEY (id);


--
-- Name: creature_images animals_creature_images_pkey; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.creature_images
    ADD CONSTRAINT animals_creature_images_pkey PRIMARY KEY (id);


--
-- Name: creature_locations animals_creature_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.creature_locations
    ADD CONSTRAINT animals_creature_locations_pkey PRIMARY KEY (id);


--
-- Name: creature animals_creature_pkey; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.creature
    ADD CONSTRAINT animals_creature_pkey PRIMARY KEY (id);


--
-- Name: creature animals_creature_scientific_name_key; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.creature
    ADD CONSTRAINT animals_creature_scientific_name_key UNIQUE (scientific_name);


--
-- Name: creature animals_creature_slug_key; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.creature
    ADD CONSTRAINT animals_creature_slug_key UNIQUE (slug);


--
-- Name: image animals_image_pkey; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT animals_image_pkey PRIMARY KEY (id);


--
-- Name: location_images animals_location_images_pkey; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.location_images
    ADD CONSTRAINT animals_location_images_pkey PRIMARY KEY (id);


--
-- Name: location animals_location_pkey; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.location
    ADD CONSTRAINT animals_location_pkey PRIMARY KEY (id);


--
-- Name: location animals_location_slug_key; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.location
    ADD CONSTRAINT animals_location_slug_key UNIQUE (slug);


--
-- Name: page animals_page_pkey; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.page
    ADD CONSTRAINT animals_page_pkey PRIMARY KEY (id);


--
-- Name: taxonomy animals_taxonomy_pkey; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.taxonomy
    ADD CONSTRAINT animals_taxonomy_pkey PRIMARY KEY (id);


--
-- Name: taxonomy animals_taxonomy_slug_key; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.taxonomy
    ADD CONSTRAINT animals_taxonomy_slug_key UNIQUE (slug);


--
-- Name: users primary; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "primary" PRIMARY KEY (id);


--
-- Name: users username; Type: CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT username UNIQUE (username);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: tower_sessions; Owner: dbuser
--

ALTER TABLE ONLY tower_sessions.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- Name: i12a1acd3_uniq; Type: INDEX; Schema: public; Owner: dbuser
--

CREATE UNIQUE INDEX i12a1acd3_uniq ON public.creature_locations USING btree (creature_id, location_id);


--
-- Name: i12f83fbe; Type: INDEX; Schema: public; Owner: dbuser
--

CREATE INDEX i12f83fbe ON public.creature_locations USING btree (creature_id);


--
-- Name: i215e8dc2; Type: INDEX; Schema: public; Owner: dbuser
--

CREATE INDEX i215e8dc2 ON public.location_images USING btree (location_id);


--
-- Name: i2e123d28; Type: INDEX; Schema: public; Owner: dbuser
--

CREATE INDEX i2e123d28 ON public.location_images USING btree (image_id);


--
-- Name: i508de5dd; Type: INDEX; Schema: public; Owner: dbuser
--

CREATE INDEX i508de5dd ON public.taxonomy USING btree (category_id);


--
-- Name: i5c2105bd; Type: INDEX; Schema: public; Owner: dbuser
--

CREATE INDEX i5c2105bd ON public.creature_locations USING btree (location_id);


--
-- Name: i62273022_uniq; Type: INDEX; Schema: public; Owner: dbuser
--

CREATE UNIQUE INDEX i62273022_uniq ON public.location_images USING btree (location_id, image_id);


--
-- Name: i6e9b6646; Type: INDEX; Schema: public; Owner: dbuser
--

CREATE INDEX i6e9b6646 ON public.creature_images USING btree (image_id);


--
-- Name: i6f2bfc9c; Type: INDEX; Schema: public; Owner: dbuser
--

CREATE INDEX i6f2bfc9c ON public.creature USING btree (genus_id);


--
-- Name: i82faf175_uniq; Type: INDEX; Schema: public; Owner: dbuser
--

CREATE UNIQUE INDEX i82faf175_uniq ON public.creature_images USING btree (creature_id, image_id);


--
-- Name: i9770c9ca; Type: INDEX; Schema: public; Owner: dbuser
--

CREATE INDEX i9770c9ca ON public.creature_images USING btree (creature_id);


--
-- Name: ic86219d4; Type: INDEX; Schema: public; Owner: dbuser
--

CREATE INDEX ic86219d4 ON public.page USING btree (image_id);


--
-- Name: creature animals_creature_genus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.creature
    ADD CONSTRAINT animals_creature_genus_id_fkey FOREIGN KEY (genus_id) REFERENCES public.taxonomy(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: creature_images animals_creature_images_creature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.creature_images
    ADD CONSTRAINT animals_creature_images_creature_id_fkey FOREIGN KEY (creature_id) REFERENCES public.creature(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: creature_images animals_creature_images_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.creature_images
    ADD CONSTRAINT animals_creature_images_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.image(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: location_images animals_location_images_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.location_images
    ADD CONSTRAINT animals_location_images_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.image(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: location_images animals_location_images_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.location_images
    ADD CONSTRAINT animals_location_images_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.location(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: page animals_page_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.page
    ADD CONSTRAINT animals_page_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.image(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: taxonomy animals_taxonomy_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.taxonomy
    ADD CONSTRAINT animals_taxonomy_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: creature_locations fk_creature_locations1; Type: FK CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.creature_locations
    ADD CONSTRAINT fk_creature_locations1 FOREIGN KEY (creature_id) REFERENCES public.creature(id);


--
-- Name: creature_locations fk_creature_locations2; Type: FK CONSTRAINT; Schema: public; Owner: dbuser
--

ALTER TABLE ONLY public.creature_locations
    ADD CONSTRAINT fk_creature_locations2 FOREIGN KEY (location_id) REFERENCES public.location(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 7TSvsPHpjf3wEE1UQGgjc927yNHOHW7bQms3fXRf5dAAUrVwCCm0auEwhdAGvQd

