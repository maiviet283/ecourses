from django.shortcuts import render,HttpResponse
from django.views import View
from rest_framework import viewsets,permissions
from .models import Course
from .serializers import CourseSerializer

class CourseViewSet(viewsets.ModelViewSet):
    queryset = Course.objects.filter(active = True)
    serializer_class = CourseSerializer
    #permission_classes = [permissions.IsAuthenticated] # xac thuc phai co admin

    def get_permissions(self):
        if self.action == 'list':
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated()]
    
    # list (GET) --> xem danh sach khoa hoc
    #.. (POST) --> them khoa hoc
    # detail --> xem chi tiet mot khoa hoc
    #.. (PUT) --> cap nhat
    #.. (DELETE) --> xoa khoa hoc



# Create your views here.
# def index(request):
#     return HttpResponse("Hello world")

# def welcome(request, year):
#     return HttpResponse("welcome " + str(year))

# def welcome2(request, year):
#     return HttpResponse("welcome " + str(year))

# class TestView(View):
#     # goi phuong thuc get gui request len dang HTTP Get
#     def get(self, request):
#         return HttpResponse("testting get")

#     # gui request len dang HTTP Post
#     def post(self, request):
#         pass