'''*****************************************************************************
Original Authors:         Haytham Shaban, Sam Waddell
Modified By:              Justin Hsia
------------------------------------------------------------------------
Project:        image_to_mif.py
------------------------------------------------------------------------
Description:    Takes in an image and outputs a corresponding black-and-white
                .mif to stdout.  Only tested with PNG files.
                To save the output to a file, use a pipe.
------------------------------------------------------------------------
Requires:       The Pillow image processing library.
*****************************************************************************'''
from PIL import Image, ImageOps
import argparse


def img2array(name, invert=False):
  # load image and convert to grayscale
  img = Image.open(name, 'r')
  img = ImageOps.grayscale(img)

  # get image data
  width, height = img.size
  pixelCount = width*height
  data = list(img.getdata())

  # print out MIF headers
  print("WIDTH=" + repr(width) + ";")
  print("DEPTH=" + repr(height) + ";\n")
  print("ADDRESS_RADIX=UNS;")
  print("DATA_RADIX=BIN;\n")
  print("CONTENT BEGIN")

  # print out MIF data (0 = black, 1 = white)
  for i in range(pixelCount):
    # add spacing if beginning of row (i.e., i divisible by width)
    if (i % width == 0):
      print("    ", end = "")
      print(repr(int((i/width))) + " \t: ", end=" ")

    # discretize to {0, 1} - min is to avoid value of 2 when data == 255
    pixel = min(1, int((data[i]*2)/255))
    print((1-pixel) if invert else pixel, end="")

    # add newline if last pixel of row
    if (i % width == width-1):
      print()

  # print out MIF footer
  print("END;")


def main():
  # argument parsing (options -h, -b, image)
  parser = argparse.ArgumentParser(description="Convert image data to black-and-white mif format")
  parser.add_argument("-i", "--invert", help="invert output so white is 0 instead of 1",
                      action="store_true")
  parser.add_argument("image", help="name of image file")
  args = parser.parse_args()

  # convert image
  img2array(args.image, args.invert)


if __name__ == '__main__':
  main()
