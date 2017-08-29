from scipy.misc import imread, imresize, imsave, fromimage, toimage
import sys

def original_color_transform(content, generated, mask=None):
    #generated = fromimage(toimage(generated, mode='RGB'), mode='YCbCr')  # Convert to YCbCr color space

    if mask is None:
        generated[:, :, 1:] = content[:, :, 1:]  # Generated CbCr = Content CbCr
    else:
        width, height, channels = generated.shape

        for i in range(width):
            for j in range(height):
                if mask[i, j] == 1:
                    generated[i, j, 1:] = content[i, j, 1:]

    generated = fromimage(toimage(generated, mode='YCbCr'), mode='RGB')  # Convert to RGB color space
    return generated

# usage: python original_color_transform.py [original_content_image] [generated_image]
print("processing", sys.argv[1])
result = original_color_transform(imread(sys.argv[1], mode='YCbCr'), imread(sys.argv[2], mode='YCbCr'))
w = 1
imsave(sys.argv[2], w*result + (1-w)*imread(sys.argv[1]))
