import xmltodict
import random
import global_values

def generate_random_q_table():
    Xmin = global_values.Xmin
    Xmax = global_values.Xmax
    Ymin = global_values.Ymin
    Ymax = global_values.Ymax
    stepX = global_values.stepX
    stepY = global_values.stepY
    global_values.set_arrays_borders()
    x = Xmin
    y = Ymin
    arrayX = []
    arrayY = []
    future_jsonX = {}
    future_jsonY = {}

    while x < Xmax:
        arrayX.append(str([float(x), float(x + stepX)]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s"))
        while y < Ymax:
            arrayY.append(str([float(y), float(y + stepY)]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s"))
            if ((global_values.Xtarget >= x) and (global_values.Ytarget >= y) and (global_values.Xtarget <= x +stepX) and (global_values.Ytarget <= y +stepY)):

                future_jsonY.update({str(arrayY[len(arrayY) - 1]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s"):
                                         {"vfh": 10.0,
                                          "bug_left": 10.0,
                                          "bug_right": 10.0}})
            else:
                future_jsonY.update({str(arrayY[len(arrayY) - 1]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s"):
                                     {"vfh": 1.1,
                                      "bug_left": 1.00001,
                                      "bug_right": float(random.random())
                                      }})
            y = y + stepY

        future_jsonX.update({str(arrayX[len(arrayX) - 1]).replace("[","l").replace("]","r").replace(",","c").replace(" ","s"): future_jsonY})
        x = x + stepX
        y = Ymin
        future_jsonY={}

    # print(future_jsonX)
    # temp = json.dumps(future_jsonX)  # конвертируем переменную в json
    # print(temp)
    # temp2 = json.loads(temp)  # конвертируем json в переменную
    # print(temp2)
    # print(temp2.get(str([0.0, 1.0])).get(str([0.0, 1.0])).get('vfh'))  # получаем значение по ключу

    future_xml = {'root': future_jsonX}

    out = xmltodict.unparse(future_xml, pretty=True)

    open("qtable.xml", "w").close()
    with open("qtable.xml", 'w') as file:
        file.write(out)


    print("Random_q_table_generated")
    # newQreward = 145.678
    # with open('qtable.json') as f:
    #     d = json.load(f)
    # d[str([0.0, 1.0])][str([0.0, 1.0])]["vfh"] = newQreward
    #
    # print(d.get(str([0.0, 1.0])).get(str([0.0, 1.0])).get('vfh'))
    #
    # with open('qtable.json', 'w') as f:
    #     json.dump(d, f, ensure_ascii=False)
    #
    # print(arrayX)
    # print(arrayY)

if __name__ == '__main__':
    generate_random_q_table()
    # Xmin=float(sys.argv[0])
    # Xmax = float(sys.argv[1])
    # Ymin=float(sys.argv[2])
    # Ymax = float(sys.argv[3])
    # stepX=float(sys.argv[4])
    # stepY = float(sys.argv[5])


