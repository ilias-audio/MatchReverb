import requests
import wget
import os
import shutil
from zipfile import ZipFile

IR_names = {"1st-baptist-nashville",
"alcuin-college-university-york",
"arthur-sykes-rymer-auditorium-university-york",
"central-hall-university-york",
"creswell-crags",
"dixon-studio-theatre-university-york",
"elveden-hall-suffolk-england",
"falkland-palace-bottle-dungeon",
"falkland-palace-royal-tennis-court",
"genesis-6-studio-live-room-drum-set",
"gill-heads-mine",
"hamilton-mausoleum",
"heslington-church-vaa-group-2",
"hoffmann-lime-kiln-langcliffeuk",
"house-of-commons-auralizations",
"innocent-railway-tunnel",
"jack-lyons-concert-hall-university-york",
"koli-national-park-summer",
"koli-national-park-winter",
"lady-chapel-st-albans-cathedral",
"Live Room (Physics and Electronic Engineering Buildings)",
"maes-howe",
"newgrange",
"r1-nuclear-reactor-hall",
"ron-cooke-hub-university-york",
"saint-lawrence-church-molenbeek-wersbeek-belgium",
"shrine-and-parish-church-all-saints-north-street-_",
"slinky-ir",
"spokane-womans-club",
"sports-centre-university-york",
"spring-lane-building-university-york",
"st-andrews-church",
"st-georges-episcopal-church",
"st-margarets-church-national-centre-early-music",
"st-margarets-church-ncem-5-piece-band-spatial-measurements",
"st-marys-abbey-reconstruction",
"st-matthews-church-walsall",
"st-patricks-church-patrington-model",
"st-patricks-church-patrington",
"stairway-university-york",
"terrys-factory-warehouse",
"terrys-typing-room",
"trollers-gill",
"tvisongur-sound-sculpture-iceland-model",
"tyndall-bruce-monument",
"usina-del-arte-symphony-hall",
"virtual-membranes",
"waveguide-web-example-audio",
"york-guildhall-council-chamber",
"york-minster"}

DOWNLOAD_FOLDER = "download"
OPEN_AIR_IR_LINK = "https://webfiles.york.ac.uk/OPENAIR/IRs/"
try:
    os.mkdir(os.getcwd()+"/" + DOWNLOAD_FOLDER)
except:
    shutil.rmtree(os.getcwd()+"/" + DOWNLOAD_FOLDER)
    os.mkdir(os.getcwd()+"/" + DOWNLOAD_FOLDER)
    
os.chdir("./" + DOWNLOAD_FOLDER)
IR_TYPE = ["mono", "stereo", "b-format", "examples" , "images"]
IR_SELECT = 2 # use this to switch between IR TYPES


for name in IR_names :
    URL = OPEN_AIR_IR_LINK + name + "/" + name + ".zip" # only folder with zips are visible on the website
    try:
        print(">>> downloading "+ name + "...") 
        wget.download(URL)
    except: 
        print(">>> [WARNING] Can't find "+ name + "!") 
        print()

for file in os.listdir():
    if file.endswith(".zip"):
        with ZipFile(file, 'r') as zipObj:
            # Extract all the contents of zip file in different directory
            print(file)
            zipObj.extractall()
            
os.chdir("../")
for currentIRType in IR_TYPE:
    try:
        shutil.rmtree("./IR_" + currentIRType)
    except:
        print()    

    os.mkdir("./IR_" + currentIRType)

    for (root,dirs,files) in os.walk("./" + DOWNLOAD_FOLDER, topdown=True):
        if currentIRType in dirs :
            dest_path = "./IR_"+ currentIRType + root[10:]
            os.mkdir(dest_path)
            files_in_folder = os.listdir(root + "/"+ currentIRType)
            for file in files_in_folder:
                print(root + "/" + currentIRType + "/" + file)
                shutil.copyfile(root + "/" + currentIRType + "/" + file, dest_path + "/" + file)
            print ('--------------------------------')

        
    