from django.shortcuts import render,HttpResponse
from django.views import View

# Create your views here.
def index(request):
    return HttpResponse("Hello world")

def welcome(request, year):
    return HttpResponse("welcome " + str(year))

def welcome2(request, year):
    return HttpResponse("welcome " + str(year))

class TestView(View):
    # goi phuong thuc get gui request len dang HTTP Get
    def get(self, request):
        return HttpResponse("testting get")

    # gui request len dang HTTP Post
    def post(self, request):
        pass