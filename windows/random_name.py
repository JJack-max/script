import random

# 100 个偏僻/中性英文名
first_names = [
    "Avery", "Ellis", "Rowan", "Soren", "Merritt", "Ashen", "Hollis", "Quinlan", "Briar", "Cypress",
    "Linden", "Perrin", "Renley", "Keir", "Tarian", "Sylas", "Corin", "Ember", "Isen", "Draven",
    "Arden", "Vale", "Fenris", "Lucan", "Eira", "Kieran", "Alaric", "Orin", "Theron", "Malin",
    "Caius", "Evander", "Callen", "Torin", "Ansel", "Lazare", "Caelan", "Orrin", "Zephyr", "Thane",
    "Eldric", "Seren", "Elion", "Nerys", "Ciran", "Dariel", "Kael", "Alwyn", "Osric", "Leif",
    "Eamon", "Cato", "Alarion", "Marius", "Renan", "Tirian", "Auren", "Galen", "Cyril", "Eldan",
    "Finlo", "Tavian", "Icarus", "Oisin", "Aeric", "Ronan", "Caelum", "Sorrel", "Hadrian", "Lorian",
    "Dorian", "Aelric", "Severn", "Evran", "Toriel", "Amiel", "Cassian", "Eldrin", "Lucien", "Cael",
    "Faelan", "Auron", "Nohr", "Thalos", "Korin", "Eryx", "Aelius", "Darion", "Kaelen", "Silvan",
    "Eryndor", "Malric", "Cyprian", "Orwin", "Thalos", "Eldros", "Caedmon", "Aedric", "Sorvin", "Tallis"
]

# 100 个偏僻姓氏
last_names = [
    "Lorne", "Marrow", "Thatch", "Vale", "Dorne", "Kade", "Greve", "Frost", "Caine", "Hale",
    "Marr", "Voss", "Stroud", "Alden", "Locke", "Bronn", "Ashford", "Talbot", "Crowe", "Whit",
    "Blythe", "North", "Haven", "Blackwood", "Storm", "Riven", "Wolfe", "Dusk", "Ravenshade", "Hollow",
    "Grimm", "Ashenford", "Thorne", "Duskwell", "Veyne", "Corven", "Fenwick", "Duskbane", "Wintermere", "Strom",
    "Darkmoor", "Graven", "Coldbrook", "Ebonhart", "Ruther", "Crowthorne", "Veynor", "Ashvale", "Draycott", "Marwick",
    "Brantham", "Evershade", "Dornell", "Fallow", "Gravesend", "Lockmere", "Weyland", "Storme", "Blackthorn", "Duskwraith",
    "Ironwood", "Greyhaven", "Ashridge", "Windmere", "Thessaly", "Crowhurst", "Rimehart", "Darkwood", "Veycroft", "Hallowell",
    "Strovane", "Rainsford", "Thryne", "Velmoor", "Oakenholt", "Coldham", "Hallowmere", "Branthorne", "Rookwell", "Ebonvale",
    "Thrayne", "Duskwind", "Veythorn", "Hawkwell", "Crowmere", "Ashlock", "Frostholm", "Stormholt", "Dravenmoor", "Isenbrook",
    "Gravenholt", "Wraithmore", "Hollowmere", "Thryngate", "Coldvale", "Ashmere", "Winterholt", "Blackmere", "Veythorn", "Duskmire"
]

def generate_names(count=10):
    names = set()
    while len(names) < count:
        first = random.choice(first_names)
        last = random.choice(last_names)
        names.add(f"{first} {last}")
    return list(names)

if __name__ == "__main__":
    for name in generate_names(10):
        print(name)
