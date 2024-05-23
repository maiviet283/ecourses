from django.urls import path, re_path
from . import views

app_name = 'courses'
urlpatterns = [
    path('', views.index, name='index'),
    path('welcome/<int:year>/', views.welcome, name='welcome'),
    re_path(r'welcome2/(?P<year>[0-9]{4})/$', views.welcome2, name='welcome2'),
    path('test/', views.TestView.as_view()),
]

# serializer : chuyen du lieu phuc tap thanh du lieu ra ben ngoai, binh thuong la json
# deserializer nguoc lai : chuyen du lieu don gian thanh du lieu phuc tap cua minh
