from PIL import Image
from math import sqrt

IMG_NAME = 'ship.png'

colors = Image.open('colors.png')
colors_ = colors.load()

colors_array = []
for y in range(colors.height):
    for x in range(colors.width):
        colors_array.append(colors_[x, y])

img = Image.open(IMG_NAME)
img = img.resize((20, 20))
img.show()
img_ = img.load()
# for x in range(img.width):
#     for y in range(img.height):
#         print(img_[x,y])

def rms(a, b):
    c = [0, 0, 0]
    for i in range(3):
        c[i] = (a[i]-b[i])**2
    c = sum(c)/len(c)
    return sqrt(c)

out = bytearray()

    #x = img.width - 1 - x
for y in range(img.height):
    for x in range(img.width):
    #    y = img.height - 1 - y
        smallest = 0xFFFFFFF
        smallest_ind = None
        for i in range(colors.height * colors.width):
            rms_ = rms(img_[x, y], colors_array[i])

            if smallest > rms_:
                smallest = rms_
                smallest_ind = i
        print(x, y, smallest_ind)
        #out.append(smallest_ind)

        with open(IMG_NAME.split('.')[0]+'.bin', 'ab') as f:
            w = bytearray([smallest_ind&0xFF])
            f.write(bytearray(w))


