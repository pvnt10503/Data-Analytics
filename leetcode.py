def plusOne(self, digits):
    for i in range(len(digits)-1,-1,-1):
        if digits[i]+1 != 10 :
            digits[i] += 1
            return digits
        else:
            digits[i] = 0
            if i == 0:
                return [1] + digits
    print(digits)
digits = [1,2,9]
plusOne(any,digits)


#Recommended Code
def merge(self, nums1, m, nums2, n) -> None:
    midx = m - 1
    nidx = n - 1 
    right = m + n - 1
    rs =[]
    while nidx >= 0:
        if midx >= 0 and nums1[midx] > nums2[nidx]:
            nums1[right] = nums1[midx]
            midx -= 1
        else:
            nums1[right] = nums2[nidx]
            nidx -= 1
        right -= 1
#My code with sorted function:
def merge(self, nums1, m, nums2, n) -> None:
    for i in range(len(nums1)):
        if i > len(nums2)-1 and nums1[i] == 0 and nums2[i - len(nums2)-1] != 0:
                nums1[i] = nums2[i-len(nums2)]
        elif len(nums1) == len(nums2) and nums1[i] == 0:
            nums1[i] = nums2[i]
    nums1 = sorted(nums1)
    print(nums1)
nums1 = [4, 7, 9, 0, 0, 0]
m = 3
nums2 = [1, 2, 3]
n = 3
merge(any,nums1,m,nums2,n)

def singleNumber(self, nums):
    nums.sort()
    for i in range(len(nums)):
        n = nums[i]
        print(n)
        nums.pop(i)
        print(nums)
        if not (n in nums):
            return n
singleNumber(any,nums)

def isPalindrome(self, s: str) -> bool:
    left = 0
    right = len(s) - 1
    while left < right:
        if not s[left].isalnum():
            left +=1
        elif not s[right].isalnum():
            right -= 1
        elif s[left].lower() == s[right].lower():
            left += 1
            right -=1
        else:
            return False
    return True

def isAnagram(self, s: str, t: str) -> bool:
    count = defaultdict(int)
    for x in s:
        count[x] += 1
    for x in t:
        count[x] -= 1
    for val in count.values():
        if val != 0:
            return False
    return True

isAnagram(any,s='rat',t='car')
num = 38
num = str(num)
def isUgly(self, n: int) -> bool:
    pf =[2,3,5]
    if n == 21:
        return False
isUgly(any,21)
pf =[2,3,5]
n = 14
def minAddToMakeValid(self, s: str) -> int:
    s ='((('
    s1 = list(s)
    r1 = s1[')']
    s1.count()
minAddToMakeValid(any,s ='(((')
del s
from collections import Counter

def intersect(nums1,nums2):
    ohio = {}
    rest_list = []
    for n in nums1:
        if n in ohio.keys():
            ohio[n] += 1
            print(ohio)
        else:
            ohio[n] = 1
            print(ohio)
    print(ohio)

    for val in nums2:
        if val in ohio.keys():
            if ohio[val] != 0:
                rest_list.append(val)
                print(rest_list)
                ohio[val] -= 1
                print(ohio)
    return rest_list

s = "abcdefghij"
s = s.split()
s.append('x'*2)
s = ''.join(s)
print(s)
            
    #buy = min(prices[i-1] for i in range(1,len(prices)) if prices[i]>prices[i-1])
    #index = prices.index(buy)
    #sell = max(prices[i] for i in range(index,len(prices)))
    #profit = sell - buy
