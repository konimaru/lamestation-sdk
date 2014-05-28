import os, sys
import files

import SpinFormatting as SF
from PIL import Image

PIXELS_PER_ADDRESS = 8
TILESIZE = 8

BITS_PER_BLOCK = 8
TRANSPARENT_COLOR = (255,0,255)

colorvalue = {}
colorvalue = {'white':{}}
colorvalue = {'black':{}}
colorvalue = {'gray':{}}
colorvalue = {'none':{}}

colorvalue['white']= {'unicode': u"\u2591", 'char': 1, 'output': (204,206,203)}
colorvalue['gray'] = {'unicode': u"\u2593", 'char': 3, 'output': (177,125,225)}
colorvalue['black']= {'unicode': u"\u2588", 'char': 0, 'output': (145,64,254)}
colorvalue['none'] = {'unicode': u" ", 'char': 2, 'output': (255,0,255)}


def getAverageColor(pixel):
    if type(pixel) is tuple:
        return sum(pixel)/3
    else:
        return pixel


def getColorValue(pixeldata):
    coloravg = getAverageColor(pixeldata)

    if pixeldata == TRANSPARENT_COLOR:
        return 'none'
    elif coloravg < 40:
        return 'black'
    elif 40 < coloravg and coloravg < 210:
        return 'gray'
    elif coloravg > 210:
        return 'white'
    else:
        raise ValueError("Bad input data")


class ImageData:

    prefix = 'gfx_'
    bitdepth = 2

    def openImage(self,filename):
        try:
            self.im = Image.open(filename)
            self.im = self.im.convert("RGB")
            self.filename = filename
            self.fullfilename = files.getFullFilename(self.prefix, self.filename, 'spin')
            self.setFrameSize(self.im.size)

        except IOError:
            print filename, "is not a valid image file"
            sys.exit(1)


    def ceilMultiple(self, x, multiple):
        if x % multiple == 0:
            return x
        else:
            return ((x/multiple)+1)*multiple


    def padFrameSize(self, framesize, size):
        return tuple([self.ceilMultiple(framesize[0], size),self.ceilMultiple(framesize[1], size)])



    def padFrames(self):
        newframesize = self.padFrameSize(self.framesize, TILESIZE)
        newsize = tuple([self.im.size[0]*newframesize[0]/self.framesize[0],self.im.size[1]*newframesize[1]/self.framesize[1]])
        newimage = Image.new("RGB",newsize)
        newimage.paste(TRANSPARENT_COLOR)

        for frame_y in range(0,self.frames_y):
            for frame_x in range(0,self.frames_x):
                x = frame_x*self.framesize[0]
                y = frame_y*self.framesize[1]

                out_x = frame_x*newframesize[0]
                out_y = frame_y*newframesize[1]

                newimage.paste(self.im.crop((x,y,x+self.framesize[0],y+self.framesize[1])),(out_x,out_y,out_x+self.framesize[0],out_y+self.framesize[1]))

        self.im = newimage
        self.setFrameSize(newframesize)

    def setFrameSize(self,framesize):
        self.framesize = framesize

        if not self.framesize <= self.im.size:
            raise ValueError("Frame "+str(self.framesize)+" is larger than image "+str(self.im.size))

        self.frameboost = (self.framesize[0]*self.bitdepth*self.framesize[1]/PIXELS_PER_ADDRESS) & 0xFFFF
        self.dimensions = (self.framesize[0] & 0xFFFF , self.framesize[1] & 0xFFFF) 
        self.frames_x = self.im.size[0]/self.framesize[0]
        self.frames_y = self.im.size[1]/self.framesize[1]

    def renderSpriteData(self):
        frame = 0
        self.spritedata = []
        for frame_y in range(0,self.frames_y):
            for frame_x in range(0,self.frames_x):

                imagedata = []
                for py in range(0,self.framesize[1]):

                    linedata = []
                    for px in range(0,self.framesize[0]):

                        x = frame_x*self.framesize[0] + px
                        y = frame_y*self.framesize[1] + py

                        pixeldata = self.im.getpixel((x,y))
                        color = getColorValue(pixeldata)
                        linedata.append(color)
                        self.im.putpixel((x,y),colorvalue[color]['output'])

                    imagedata.append(linedata)
                self.spritedata.append(imagedata)
                frame += 1

        return self.spritedata

    def assembleSpinHeader(self,image):
        output = ""

        output += SF.commentBox(\
                str(self.prefix)+os.path.splitext(os.path.basename(self.filename))[0]+".spin\n"\
                +"Graphics generated by img2dat")

        output += SF.addrBox(self.prefix)
        return output

    def assembleWordHeader(self,image):
        output = ""
        output += "word    "+str(self.frameboost)+" ' frameboost\n"
        output += "word    "+str(len(image[0]))+", "+str(len(image))+" ' width, height\n"
        return output


    def assembleLine(self, line, radix):
        output = ""
        colordata = 0

        for x in range(0,len(line)):

            if radix == 'hex':
                if x % BITS_PER_BLOCK == 0:
                    colordata = 0

                colordata += (colorvalue[line[x]]['char'] << ((x % BITS_PER_BLOCK)*2))

                if x % BITS_PER_BLOCK == 7:
                    output += "$"+hex(colordata)[2:].zfill(BITS_PER_BLOCK/2)
                    if x < (len(line)-1):
                        output += ","

            elif radix == 'quaternary':

                if x % BITS_PER_BLOCK == 0:
                    output += "%%"

                xindex = (x/BITS_PER_BLOCK)*BITS_PER_BLOCK + BITS_PER_BLOCK-1 - x % BITS_PER_BLOCK
                output += str(colorvalue[line[xindex]]['char'])

                if x % BITS_PER_BLOCK == 7:
                    if x < (len(line)-1):
                        output += ","

            elif radix == 'unicode':
                output += colorvalue[line[x]]['unicode'].encode('utf-8')
        return output


    def assembleData(self, image, radix):
        output = ""

        for y in range(0,len(image)):
            if radix == 'both':
                output += "\nword    "
                output += self.assembleLine(image[y], 'hex')
                output += " ' "
                output += self.assembleLine(image[y], 'unicode')
            else:
                if radix == 'unicode':
                    output += "\n' "
                else:
                    output += "\nword    "
                output += self.assembleLine(image[y], radix)


        return output

    def assembleSpinFile(self, spritedata):
        output = ""
        output += self.assembleSpinHeader(spritedata[0])
        output += "\n\n"

        output += self.assembleWordHeader(spritedata[0])

        frame = 0
        for s in spritedata:
            output += "' frame "+str(frame)
            output += self.assembleData(s,'both')
            output += "\n"
            frame += 1
        output += "\n"

        return output


    def writeSpinFile(self,spin):
        f = open(self.fullfilename,"w")
        f.write(spin)
        f.close()


    def printImageTag(self):
        print "'   Creating:",self.fullfilename
        print "'  Bit depth:",self.bitdepth
        print "' Image Type:",self.mode
        print "' Image size:",self.im.size
        print "' Frame size:",self.framesize
        print "'     Frames:",self.frames_x,",",self.frames_y

