from django.db import models
from django.contrib.auth.models import AbstractUser
from ckeditor.fields import RichTextField
# Create your models here.

class User(AbstractUser):
    avatar = models.ImageField(upload_to='uploads/%Y/%m')

class Category(models.Model): #courses_category
    name = models.CharField(null=False, unique=True, max_length=100) # ko dc trung ten unique=True

    def __str__(self):
        return self.name
    
# cai nay chi la cai chung ko phai table trong db => nen phai co class meta
class ItemBase(models.Model):
    class Meta:
        abstract = True

    subject = models.CharField(max_length=100, null=False)
    # MEDIA_ROOT + upload_to
    image = models.ImageField(upload_to='courses/%Y/%m', default=None)
    created_date = models.DateTimeField(auto_now_add=True) # luu ca gio luon,thoi diem hien tai, luc tao thoi
    updated_date = models.DateTimeField(auto_now=True) # chi can sua doi la cap nhat lien tuc
    active = models.BooleanField(default=True) # mac dinh la true, chi hien

    def __str__(self):
        return self.subject
    

class Course(ItemBase):
    class Meta:
        unique_together = ('subject', 'category')
        ordering = ["id"] # sap xep theo id
        # trong 1 danh muc khong duoc phep trung ten danh muc
    description = models.TextField(null=True, blank=True) # nhap nhieu
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True)


class Lesson(ItemBase):
    class Meta:
        unique_together = ('subject', 'course')
        # trong 1 khoa hoc ko dc cung ten bai hoc
    content = RichTextField()
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='lessons') #PROJECT ko dc xoa, trai nguoc CASADE
    tags = models.ManyToManyField('Tag', blank=True, null=True, related_name='lessons') # co the Tag ko can '', nhung Tag o duoi


class Tag(models.Model):
    name = models.CharField(max_length=50, unique=True)

    def __str__(self):
        return self.name

