# BoxBloom

一个轻量级的Love2D演示项目，展示了使用盒型滤波（Box Filters）实现的泛光（Bloom）效果。

## 项目说明

本项目实现了基于盒型滤波的高效模糊算法，相比传统的高斯模糊，具有以下优势：
- 采样次数与模糊半径无关，固定为有限次数
- 在移动端等性能受限设备上表现更佳
- 视觉效果与高斯模糊相近

## 使用方法

- 上/下箭头键：调整亮度阈值
- 左/右箭头键：调整模糊半径
- +/-键：调整泛光强度
- 拖动中间白线：比较原图与效果图

## 实现原理

传统的高斯模糊需要对每个像素周围进行大量采样，采样次数随模糊半径增加而增加。盒型滤波通过模拟不同级别的mipmap采样，使得采样次数只与模拟的级别数量相关，而与模糊半径无关。

## 论文出处

本项目基于以下论文实现：
[The Power of Box Filters: Real-time Approximation to Large Convolution Kernel by Box-filtered Image Pyramid](https://www.researchgate.net/publication/337301359_The_Power_of_Box_Filters_Real-time_Approximation_to_Large_Convolution_Kernel_by_Box-filtered_Image_Pyramid)

