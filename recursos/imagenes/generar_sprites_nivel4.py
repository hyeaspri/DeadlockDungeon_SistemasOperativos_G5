# Sprites del nivel 4 (mismo estilo chibi que gen2.py)
import os
from PIL import Image, ImageDraw
OUT=os.path.join(os.path.dirname(os.path.abspath(__file__)),'imagenes')+os.sep
os.makedirs(OUT,exist_ok=True)
K=(24,16,28,255); T=(0,0,0,0)
def C(r,g,b): return (r,g,b,255)
def outline(img):
    w,h=img.size; s=img.load(); o=img.copy(); d=o.load()
    for y in range(h):
        for x in range(w):
            if s[x,y][3]==0:
                for dx,dy in((1,0),(-1,0),(0,1),(0,-1)):
                    nx,ny=x+dx,y+dy
                    if 0<=nx<w and 0<=ny<h and s[nx,ny][3]>0 and s[nx,ny]!=K: d[x,y]=K;break
    return o
def R(d,a,b,c,e,col): d.rectangle([a,b,c,e],fill=col)
def E(d,a,b,c,e,col): d.ellipse([a,b,c,e],fill=col)
def P(d,x,y,c): d.point((x,y),fill=c)
def save(img,n,s): img.resize((img.width*s,img.height*s),Image.NEAREST).save(OUT+n+'.png')
SK1=C(255,222,196);SK2=C(240,184,152);SK3=C(206,140,120)
EY=C(30,22,40);WH=C(255,255,255);CH=C(250,150,150)
G1=C(120,200,110);G2=C(70,150,70);G3=C(40,100,50);G4=C(26,66,34)
BR1=C(170,112,62);BR2=C(124,78,42);BR3=C(80,48,28)
GO1=C(255,230,120);GO2=C(238,182,52);GO3=C(176,112,30)
HA=C(150,80,40)
def cara(d,cx,y):
    for ex in (cx-5,cx+3):
        R(d,ex,y,ex+1,y+2,EY); P(d,ex,y,WH)
    for x in (cx-7,cx-6,cx+5,cx+6): P(d,x,y+3,CH)
    R(d,cx-1,y+4,cx,y+4,SK3)
# ================= ARQUERO 38x40 =================
im=Image.new('RGBA',(38,40),T); d=ImageDraw.Draw(im)
# carcaj en la espalda (flechas asomando)
R(d,25,8,28,22,BR2); R(d,25,8,25,22,BR1)
for x,c in ((25,C(220,220,230)),(27,C(220,220,230))): R(d,x,4,x,8,BR3); P(d,x,3,c); P(d,x-1,4,C(230,80,80)); P(d,x+1,4,C(230,80,80))
# arco a la izquierda
d.arc([0,8,12,36],100,260,fill=BR2,width=2); d.line([5,9,5,35],fill=C(230,230,230),width=1)
# piernas y botas
R(d,13,32,17,36,BR2); R(d,20,32,24,36,BR2); R(d,12,36,17,38,BR3); R(d,20,36,25,38,BR3)
# tunica
R(d,11,22,26,32,G2); R(d,11,22,13,32,G1); R(d,23,22,26,32,G3)
R(d,11,28,26,29,BR2); R(d,17,28,19,29,GO2)
d.line([12,22,25,31],fill=BR2,width=1)   # correa del carcaj
# brazos
R(d,7,23,10,29,G2); R(d,6,28,9,30,SK2); R(d,27,23,30,29,G3); R(d,28,28,31,30,SK2)
# capucha grande
E(d,8,4,29,25,G2); E(d,9,5,22,15,G1); E(d,19,10,29,24,G3)
d.polygon([(18,1),(22,0),(20,6)],fill=G2)
# cara dentro de la capucha
E(d,11,10,26,23,SK2); E(d,12,10,24,21,SK1)
R(d,12,10,25,11,HA); P(d,13,12,HA); P(d,24,12,HA)   # flequillo
cara(d,19,14)
R(d,9,20,28,23,G3); R(d,10,20,27,20,G2)             # borde de la capucha
im=outline(im); save(im,'spr_arquero',3)
# ================= ANTORCHA 22x24 =================
im=Image.new('RGBA',(22,24),T); d=ImageDraw.Draw(im)
R(d,9,11,12,22,BR2); R(d,9,11,9,22,BR1); R(d,12,11,12,22,BR3)
R(d,8,13,13,14,C(150,150,160)); R(d,8,17,13,18,C(150,150,160))   # aros de metal
R(d,7,9,14,11,BR3)
d.polygon([(6,9),(15,9),(14,5),(12,2),(11,0),(10,3),(8,5)],fill=C(236,100,30))
d.polygon([(8,9),(13,9),(12,5),(11,2),(9,5)],fill=C(255,170,40))
R(d,10,5,11,8,C(255,240,170))
im=outline(im); save(im,'spr_antorcha',3)
print('ok')
