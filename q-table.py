import json
import random

if __name__ == '__main__':

    # Xmin=float(sys.argv[0])
    # Xmax = float(sys.argv[1])
    # Ymin=float(sys.argv[2])
    # Ymax = float(sys.argv[3])
    # stepX=float(sys.argv[4])
    # stepY = float(sys.argv[5])

    Xmin=0
    Xmax = 5
    Ymin=0
    Ymax = 5
    stepX=1
    stepY = 1
    x=Xmin
    y=Ymin
    arrayX = []
    arrayY = []
    future_jsonX= {}
    future_jsonY= {}
    future_jsonAll= {}

    while x<Xmax:
        arrayX.append([float(x),float(x+stepX)])
        while y<Ymax:
            arrayY.append([float(y), float(y + stepY)])
            future_jsonY.update({str(arrayY[len(arrayY)-1]):
                                {"vfh": float(random.random()),
                                "bug_left": float(random.random()),
                                "bug_right": float(random.random())}})
            y=y+stepY

        future_jsonX.update({str(arrayX[len(arrayX)-1]):future_jsonY})
        x = x + stepX
    print(future_jsonX)
    temp=json.dumps(future_jsonX) #конвертируем переменную в json
    print(temp)
    temp2=json.loads(temp) # конвертируем json в переменную
    print(temp2)
    print(temp2.get(str([0.0,1.0])).get(str([0.0,1.0])).get('vfh')) #получаем значение по ключу
    #
    #
    # arrayX = [[0, 1], [1, 2], [2, 3]]
    #
    # x = str(arrayX[0])
    # print(x)
    #
    # # a Python object (dict):
    # x = {
    #     "[0,1]": [
    #         {"[0,1]": {"vfh": 0.9,
    #                    "bug_left": 0.8,
    #                    "bug_right": 0.5}
    #          },
    #         {"[1,2]": {"vfh": 0.9,
    #                    "bug_left": 0.8,
    #                    "bug_right": 0.5}
    #          },
    #         {"[2,3]": {"vfh": 0.9,
    #                    "bug_left": 0.8,
    #                    "bug_right": 0.5}
    #          },
    #     ],
    #     "[1,2]": [
    #         {"[0,1]": {"vfh": 0.9,
    #                    "bug_left": 0.8,
    #                    "bug_right": 0.5}
    #          },
    #         {"[1,2]": {"vfh": 0.9,
    #                    "bug_left": 0.8,
    #                    "bug_right": 0.5}
    #          },
    #         {"[2,3]": {"vfh": 0.9,
    #                    "bug_left": 0.8,
    #                    "bug_right": 0.5}
    #          },
    #     ],
    #
    #     "[2,3]": [
    #         {"[0,1]": {"vfh": 0.9,
    #                    "bug_left": 0.8,
    #                    "bug_right": 0.5}
    #          },
    #         {"[1,2]": {"vfh": 0.9,
    #                    "bug_left": 0.8,
    #                    "bug_right": 0.5}
    #          },
    #         {"[2,3]": {"vfh": 0.9,
    #                    "bug_left": 0.8,
    #                    "bug_right": 0.5}
    #          },
    #     ]
    #
    # }
    #
    # # convert into JSON:
    # y = json.dumps(x)
    #
    # # the result is a JSON string:
    # print(y)