import sys
import time

procedure_calls = 0
window_depth = 0
overflows = 0
underflows = 0
register_count = 15

def ackermann(x, y, s = "%s"):
    # print(s % ("ackermann(%d, %d)" % (x, y)))

    global procedure_calls, window_depth, overflows, underflows, register_count
    procedure_calls += 1

    ret_val = 0

    if(window_depth == register_count):
        overflows += 1
    else:
        window_depth += 1

    if(x == 0):
        ret_val = y+1
    elif(y == 0):
        ret_val = ackermann(x-1, 1, s)
    else:
        ret_val = ackermann(x-1, ackermann(x, y-1, s % ("ackermann(%d, %%s)" % (x-1))), s)

    if(window_depth < 1):
        underflows += 1
    else:
        window_depth -= 1

    return ret_val

def main(isInstrumented = False):
    if isInstrumented == True:
        v = 0
        ack_n = 10
        three = 3
        six = 6
        start_time = time.time()

        #prevent the compiler from optimising by using volatility
        for i in range(0, ack_n):
            three = 3
            six = 6
            v += ackermann(three, six)

        print("Ackermann: %d" % int(v / ack_n))

        # get time in ns with respect to clock cycle of CPU and overall cycles
        total_time = (time.time() - start_time) * 1000 / time.clock() / ack_n
        print("{0:.2f}".format(round(total_time, 2)) + "ns")

    else:
        print("%d return value, %d calls, %d overflows, %d underflows" %
            (ackermann(3,6), procedure_calls, overflows, underflows))

if(__name__ == "__main__"):
    if sys.argv[1] == "instrumented":
        main(True)
    else:
        main()
